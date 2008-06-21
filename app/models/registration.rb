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

class Registration < ActiveRecord::Base

  def sale?; false; end

  has_finder :with_period, lambda { |period| { :conditions => ["created_at BETWEEN ? AND ?", period.first, period.last] } }
  has_finder :with_payment, :conditions => "payment_status = 'Complete'"
  has_finder :with_opt_in,  :conditions => "contact_approval = 1"
  has_finder :orders,       :conditions => "type = 'PrivateOrder' or type = 'CompanyOrder'"

  has_finder :global_parents, :conditions => "type = 'GlobalParent'"
  has_finder :donations,      :conditions => "type = 'PrivateDonation' or type = 'CompanyDonation'"

  has_finder :of_the_type, lambda { |class_type| { :conditions => ["type = ?", class_type.classify] } }

  has_finder :invalid_orders,   :conditions => ["(payment_type != ? AND payment_transaction_id IS NULL) OR (dispatch_id IS NULL AND (payment_status IS NULL OR payment_status != ?))", 'invoice', 'Denied']

  has_one :payment, :as => :payable
  has_one :conversion
  belongs_to :node
  belongs_to :registration_form
    
  before_validation_on_create :generate_public_id
  validates_presence_of :payment_type, :if => Proc.new { |r| r.payable? }

  # for strd limitations
  validates_length_of :address, :maximum => 40, :allow_nil => true
  validates_length_of :shipping_address, :maximum => 40, :allow_nil => true
  validates_length_of :email, :maximum => 127, :allow_nil => true
  validates_length_of :phone, :maximum => 20, :allow_nil => true
  validates_length_of :first_name, :maximum => 20, :allow_nil => true
  validates_length_of :last_name, :maximum => 20, :allow_nil => true
  
  
  delegate :send_email_response?, :replyable_email?, :reply_to_email, :email_subject, :email_body, :parsed_email_body, :contact_person, :notification_person, :to => :registration_form

  composed_of :total_sum, :class_name => "Money", :mapping => %w(total_sum cents) do |total_sum|
    total_sum.to_money rescue 0.to_money
  end
  composed_of :total_vat, :class_name => "Money", :mapping => %w(total_vat cents) do |total_vat| 
    total_vat.to_money rescue 0.to_money
  end
  composed_of :shipment_price, :class_name => "Money", :mapping => %w(shipment_price cents) do |shipment_price|
    shipment_price.to_money rescue 0.to_money
  end
  composed_of :shipment_vat, :class_name => "Money", :mapping => %w(shipment_vat cents) do |shipment_vat|
    shipment_vat.to_money rescue 0.to_money
  end
  composed_of :donation, :class_name => "Money", :mapping => %w(donation cents) do |donation|
    donation.to_money rescue 0.to_money
  end
  
  is_indexed :fields => ['type', 'first_name', 'last_name', 'customer_number', 'email', 'organization', 'address', 
                         'locality', 'shipping_first_name', 'shipping_last_name','shipping_organisation', 'shipping_address', 
                         'shipping_locality', 'public_id', 'message', 'school', 'payment_transaction_id', 'dispatch_id']
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def shipping_name
    "#{shipping_first_name} #{shipping_last_name}"
  end
  
  def name=(names )
    names      = names.split(" ")
    self.first_name = names.shift
    self.last_name  = names.join(" ") if names
    name
  end
  
  def to_url
    self.class.to_s.underscore
  end

  def payable?
    false
  end

  def total_amount_gross
    total_sum
  end
  
  def chargeable_amount
    total_amount_gross
  end

  # overide this in subclasses for more precise purchase types (donation targets, reacurring global parents ect.)
  def purchase_type
    to_url
  end

  # overide this in subclasses for more precise purchase names
  def purchase_name
    self.class.to_s
  end

  def build_debitech_purchase
    [purchase_type, purchase_name, 1, total_sum.cents].join(':')+":"
  end
  
  # Default fields for cvs export, overwrite this in submodels if needed
  def cvs_fields
    [
      created_at.strftime("%Y-%m-%d %H:%M"),
      first_name,
      last_name,
      address,
      post_code,
      locality,
      email,
      contact_approval.to_s,
      total_sum.cents/100,
      ((conversion and conversion.measure_point) ? conversion.measure_point.public_id : ''),
      id
    ]
  end

  # Use cvs fields and convert to latin1 comma seperated string
  def to_cvs_s
    cvs_fields.collect { |value| "\"#{ value.to_s.to_latin1 }\""}.join(',')
  end

  class << self
    def new_from_type(registration_type, attributes = {}, allowed_types = 'all')
      raise SecurityTransgression if allowed_types.is_a?(Array) and not allowed_types.include?(registration_type)
      raise SecurityTransgression unless Registration.valid_registration_types.include?(registration_type)
      registration_type.constantize.new(attributes)
    end
    
    def valid_registration_types
      [
        'WillInformationOrder',
        'GlobalParent',
        'Donation',
        'PrivateDonation',
        'CompanyDonation',
        'Order',
        'WaterDropOrder',
        'ChristmasCardsOrder',
        'NewsletterSubscription',
        'ActivityGroupMembership',
        'SampleProductOrder',
        'PageTip',
        'GlobalParentGiveAway',
        'VgDonation',
        'MemoriumGiftDonation',
        'CongratulationGiftDonation'
      ]
    end

    def average_sum(options = {})
      sql = "select sum(total_sum) / count(*) from registrations where type = '#{self.to_s}'"
      sql += " and created_at between '#{options[:period].first.to_s(:db)}' and '#{options[:period].last.to_s(:db)}'" if options[:period]
      Money.new(connection.select_value(sql).to_f.round)
    end

    def total_sum(options = {})
      sql = "select sum(total_sum) from registrations where type = '#{self.to_s}'"
      sql += " and created_at between '#{options[:period].first.to_s(:db)}' and '#{options[:period].last.to_s(:db)}'" if options[:period]
      Money.new(connection.select_value(sql).to_f.round)
    end

    def export(period)
      period.blank? ? find(:all) : with_period(period).find(:all)
    end
    
    def export_count(last_export = false)
      last_export ? count(:conditions => ['created_at > ?', last_export]) : count
    end
    
    def find_for_export(from, through)
      find(:all, :conditions => "registrations.created_at > '#{from.to_s(:db)}' AND registrations.created_at <= '#{through.to_s(:db)}'", :order => 'registrations.created_at')
    end
  end

protected

  def generate_public_id
    chars = ("a".."z").to_a + ("1".."9").to_a 
    self.public_id = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{Array.new(32, '').collect{chars[rand(chars.size)]}.join}--")
  end

  def validate
    # errors.add(:type, "has invalid format") if type Registration.valid_registration_types.include?(self.class.to_s)
  end

end
