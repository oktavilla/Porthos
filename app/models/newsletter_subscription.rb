# == Schema Information
# Schema version: 76
#
# Table name: registrations
#
#  id                       :integer(11)   not null, primary key
#  type                     :string(255)   
#  first_name               :string(255)   
#  last_name                :string(255)   
#  customer_number          :string(255)   
#  age                      :integer(11)   
#  email                    :string(255)   
#  phone                    :string(255)   
#  cell_phone               :string(255)   
#  organization             :string(255)   
#  department               :string(255)   
#  organization_number      :string(255)   
#  address                  :string(255)   
#  post_code                :string(255)   
#  locality                 :string(255)   
#  country                  :string(255)   
#  shipping_address         :string(255)   
#  shipping_post_code       :string(255)   
#  shipping_locality        :string(255)   
#  shipping_country         :string(255)   
#  contact_approval         :boolean(1)    
#  total_sum                :integer(11)   default(0), not null
#  total_vat                :integer(11)   default(0), not null
#  total_items              :integer(11)   
#  payment_id               :integer(11)   
#  payment_type             :string(255)   
#  payment_transaction_id   :string(255)   
#  payment_status           :string(255)   
#  payment_response_message :string(255)   
#  public_id                :string(255)   
#  user_id                  :integer(11)   
#  shop_id                  :integer(11)   
#  dispatch_id              :string(255)   
#  dispatch_status          :string(255)   
#  shipment_id              :string(255)   
#  shipment_type            :string(255)   
#  message                  :string(255)   
#  node_id                  :integer(11)   
#  created_at               :datetime      
#  updated_at               :datetime      
#  registration_form_id     :integer(11)   
#  donation                 :integer(11)   default(0), not null
#  shipment_price           :integer(11)   default(0), not null
#  activity_group_id        :integer(11)   
#  school                   :string(255)   
#  school_class             :string(255)   
#  number_of_persons        :integer(11)   
#  uri                      :string(255)   
#  recipients               :string(255)   
#  target_code              :string(255)   
#  shipment_vat             :integer(11)   default(0)
#  shipping_organisation    :string(255)   
#

class NewsletterSubscription < Registration
  validates_presence_of :email
  validates_as_email :email, :message => l(:validators, :bad_email_format)
  
  before_save :allow_contact_approval
  
  class << self
    def export(period)
      find_by_sql ["SELECT id, created_at, first_name, last_name, email FROM registrations WHERE (created_at BETWEEN ? AND ?) AND (type != ? AND type != ? AND (status = 1 OR status = 3)) AND contact_approval = ?", period.first, period.last, 'GlobalParent', 'PrivateDonation', '1']
    end
    
    def cvs_fields
      [
        :created_at_date,
        :created_at_time,
        :first_name,
        :last_name,
        :email,
        :conversion_point_id,
        :id
      ]
    end
  end
  
protected
  def allow_contact_approval
    self.contact_approval = 1
  end
end
