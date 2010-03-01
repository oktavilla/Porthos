# == Schema Information
# Schema version: 76
#
# Table name: conversions
#
#  id                :integer(11)   not null, primary key
#  measure_point_id  :integer(11)   
#  registration_id   :integer(11)   
#  registration_type :string(255)   
#  amount            :integer(11)   default(0), not null
#  created_at        :datetime      
#  updated_at        :datetime      
#

class Conversion < ActiveRecord::Base
  belongs_to :measure_point, :counter_cache => true
  belongs_to :registration,  :polymorphic => true
  
  named_scope :by_type, lambda { |type| { :conditions => ["registration_type = ?", type] } }
  named_scope :confirmed, :conditions => 'status = 1', :joins => 'LEFT JOIN registrations ON registrations.id = conversions.registration_id'

  composed_of :amount,
              :class_name => "Money",
              :mapping => %w(amount cents),
              :converter => Proc.new { |amount| amount.to_money }
 
  class << self
    def from_click(measure_point_id, registration)
      create(:measure_point_id  => measure_point_id, 
             :registration_id   => registration.id, 
             :registration_type => registration.class.to_s)
    end
    
    def from_payment(measure_point_id, registration)
      create(:measure_point_id  => measure_point_id, 
             :registration_id   => registration.id, 
             :registration_type => registration.class.to_s,
             :amount            => registration.total_sum )
    end
  end
end
