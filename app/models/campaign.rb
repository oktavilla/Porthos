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
  has_many :conversions, :through => :measure_points do
    def count_confirmed_registrations(args = {})
      options = { :joins => 'LEFT JOIN registrations ON conversions.registration_id = registrations.id' }
      if arg_conditions = args.delete(:conditions)
        options[:conditions] = 'registrations.status = 1 AND ' + sanitize_sql_for_conditions(arg_conditions)
      else
        options[:conditions] = 'registrations.status = 1'
      end
      count(options.merge(args))
    end
  end

  named_scope :active,   :conditions => 'active = 1'
  named_scope :archived, :conditions => 'active = 0'
  
  validates_presence_of :name
  
  is_indexed :fields => ['name', 'dp_buyer_code', 'dp_donor_code'],
                         :concatenate => [{:association_name => 'measure_points', :field => 'name', :as => 'measure_points'}, 
                                          {:association_name => 'measure_points', :field => 'public_id', :as => 'measure_points_ids'}]
  
  def cost
    Money.new(measure_points.sum(:cost) || 0)
  end
  
  def income(registration_type = false)
    if conversions.detect { |conversion| conversion.registration } != nil
      query = "SELECT 
        sum(payments.amount) AS sum_amount 
        FROM conversions 
        INNER JOIN measure_points ON conversions.measure_point_id = measure_points.id
         LEFT JOIN registrations ON conversions.registration_id = registrations.id " 
      query <<  "LEFT JOIN payments ON conversions.registration_id = payments.payable_id
        WHERE measure_points.campaign_id = #{self.id} AND (payments.status = 'Completed' OR payments.billing_method = 'invoice') AND registrations.status = 1"
      query << " AND registration_type = '#{registration_type}'" unless registration_type.blank?
      amount = Campaign.find_by_sql(query)[0]['sum_amount'].to_i
    else 
      amount = conversions.sum(:amount, {:joins => 'LEFT JOIN registrations ON conversions.registration_id = registrations.id', :conditions => ['registrations.status = 1']})
    end
    Money.new(amount || 0)
  end
  
  def total_conversions
    query = "SELECT count(conversions.id) as conversions_count FROM conversions
     INNER JOIN measure_points ON conversions.measure_point_id = measure_points.id
     LEFT JOIN registrations ON conversions.registration_id = registrations.id 
     WHERE measure_points.campaign_id = #{self.id} AND registrations.status = 1"
    (Campaign.find_by_sql(query)[0]['conversions_count'].to_i || 0)
  end
  
  def clicks
    measure_points.sum(:num_clicks)
  end
  
  def roi
    if cost.cents > 0
      (income.cents.to_f-cost.cents.to_f/cost.cents.to_f) * 100
    else
      0
    end
  end
  
end
