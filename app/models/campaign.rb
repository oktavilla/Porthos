# == Schema Information
# Schema version: 76
#
# Table name: campaigns
#
#  id                    :integer(11)   not null, primary key
#  name                  :string(255)   
#  dp_global_parent_code :string(255)   
#  dp_buyer_code         :string(255)   
#  dp_donor_code         :string(255)   
#  active                :boolean(1)    default(TRUE)
#  created_at            :datetime      
#  updated_at            :datetime      
#

class Campaign < ActiveRecord::Base
  has_many :measure_points
  has_many :conversions, :through => :measure_points

  has_finder :active,   :conditions => 'active = 1'
  has_finder :archived, :conditions => 'active = 0'
  
  validates_presence_of :name
  
  def cost
    Money.new(measure_points.sum(:cost) || 0)
  end
  
  def income(registration_type = false)
    if conversions.detect { |conversion| conversion.registration } != nil
      query = "SELECT 
        sum(payments.amount) AS sum_amount 
        FROM conversions 
        INNER JOIN measure_points ON conversions.measure_point_id = measure_points.id "
      query << "LEFT JOIN registrations ON conversions.registration_id = registrations.id " unless registration_type.blank?
      query <<  "LEFT JOIN payments ON conversions.registration_id = payments.payable_id
        WHERE measure_points.campaign_id = #{self.id} AND (payments.status = 'Completed' OR payments.billing_method = 'invoice')"
      query << " AND registration_type = '#{registration_type}'" unless registration_type.blank?
      amount = Campaign.find_by_sql(query)[0]['sum_amount'].to_i
    else 
      amount = conversions.sum(:amount)
    end
    Money.new(amount || 0)
  end
  
  def clicks
    measure_points.sum(:num_clicks)
  end
  
  def total_conversions
    measure_points.sum(:conversions_count)
  end
  
  def roi
    if cost.cents > 0
      (income.cents.to_f-cost.cents.to_f/cost.cents.to_f) * 100
    else
      0
    end
  end
  
end
