# == Schema Information
# Schema version: 76
#
# Table name: measure_points
#
#  id                :integer(11)   not null, primary key
#  name              :string(255)   
#  link_type         :integer(11)   
#  target            :integer(11)   
#  cost              :integer(11)   default(0), not null
#  public_id         :string(255)   
#  num_clicks        :integer(11)   default(0)
#  campaign_id       :integer(11)   
#  conversions_count :integer(11)   default(0)
#  created_at        :datetime      
#  updated_at        :datetime      
#

class MeasurePoint < ActiveRecord::Base
  belongs_to :campaign
  has_many   :conversions, :order => 'created_at DESC'

  # See config/languages/sv.yaml
  LINK_TYPES = { :banner_flash => 1, :banner_gif => 2, :text_link => 3 }
  TARGETS    = { :global_parents => 1, :private_donations => 2, :private_buys => 3 }
  
  before_create :create_public_id
  
  composed_of :cost, :class_name => "Money", :mapping => %w(cost cents) do |cost|
    cost.to_money
  end
  
  def link_type_name
    l(:measure_point, :link_types, LINK_TYPES.index(link_type)) rescue ''
  end
  
  def target_name
    l(:measure_point, :targets, TARGETS.index(target)) rescue ''
  end
  
  def total_conversions
    conversions.count
  end
  
  def income(registration_type = false)
    if conversions.detect { |conversion| conversion.registration } != nil
      query = "SELECT 
        sum(payments.amount) AS sum_amount 
        FROM conversions 
        INNER JOIN measure_points ON conversions.measure_point_id = measure_points.id "
      query << "LEFT JOIN registrations ON conversions.registration_id = registrations.id " unless registration_type.blank?
      query << "LEFT JOIN payments ON conversions.registration_id = payments.payable_id
        WHERE measure_points.id = #{self.id} AND (payments.status = 'Completed' OR payments.billing_method = 'invoice')"
      query << " AND registration_type = '#{registration_type}'" unless registration_type.blank?
      amount = MeasurePoint.find_by_sql(query)[0]['sum_amount'].to_i
    else 
      amount = conversions.sum(:amount)
    end
    Money.new(amount || 0)
  end
  
  def roi
    if cost.cents > 0
      (income.cents.to_f-cost.cents.to_f/cost.cents.to_f) * 100
    else
      0
    end
  end
  
protected
  def create_public_id
    chars = ("a".."z").to_a + ("1".."9").to_a 
    self.public_id = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{Array.new(32, '').collect{chars[rand(chars.size)]}.join}--")[0...6].upcase
  end
end
