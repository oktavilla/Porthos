class Registration < ActiveRecord::Base

  def sale?; false; end
  def needs_confirmation?; false; end

  acts_as_filterable

  class_inheritable_accessor :public_filters
  self.public_filters = [
    :confirmed,
    :pending,
    :failed,
    :spam,
    :fraud
  ]

  class_inheritable_accessor :valid_registration_types
  self.valid_registration_types = []

  named_scope :with_opt_in,   :conditions => "contact_approval = 1"

  named_scope :pending,       :conditions => "status = 0"
  named_scope :confirmed,     :conditions => 'status = 1'
  named_scope :spam,          :conditions => 'status = 2'
  named_scope :failed,        :conditions => 'status = 3'
  named_scope :fraud,         :conditions => 'fraud = 1'

  named_scope :confirmed_or_pending, :conditions => '(status = 1 or status = 0)'

  named_scope :with_period, lambda { |period| { :conditions => ["created_at BETWEEN ? AND ?", period.first, period.last] } }
 
  named_scope :filter_of_the_type, lambda { |class_type| { :conditions => ["type = ?", class_type.classify] } }

  has_many :comments, :class_name => 'RegistrationComment'
  has_many :related_registrations, :class_name => 'Registration', :finder_sql => 'SELECT * FROM registrations WHERE registrations.session_id = "#{session_id}" AND id != "#{id}"'
  belongs_to :node
  belongs_to :registration_form
  belongs_to :user
  
  attr_accessor :trigger  
  validates_length_of :trigger, :is => 0, :allow_nil => true
  
  attr_accessor :env
  
  attr_accessor :should_create_user
  
  def should_create_user?
    should_create_user == true || should_create_user.to_s.to_i == 1
  end
  
  before_validation_on_create :generate_public_id, :set_current_user
  
  delegate :send_email_response?, :replyable_email?, :reply_to_email, :email_subject, :email_body, :parsed_email_body, :contact_person, :notification_person, :to => :registration_form

  composed_of :total_sum,
              :class_name => "Money",
              :mapping => %w(total_sum cents),
              :converter => Proc.new { |total_sum| total_sum.to_money rescue 0.to_money }
  composed_of :total_vat,
              :class_name => "Money",
              :mapping => %w(total_vat cents),
              :converter => Proc.new { |total_vat| total_vat.to_money rescue 0.to_money }
  composed_of :shipment_price,
              :class_name => "Money",
              :mapping => %w(shipment_price cents),
              :converter => Proc.new { |shipment_price| shipment_price.to_money rescue 0.to_money }
  composed_of :shipment_vat,
              :class_name => "Money",
              :mapping => %w(shipment_vat cents),
              :converter => Proc.new { |shipment_vat| shipment_vat.to_money rescue 0.to_money }
  composed_of :donation,
              :class_name => "Money",
              :mapping => %w(donation cents),
              :converter => Proc.new { |donation| donation.to_money rescue 0.to_money }
  
  is_indexed({
    :fields => ['public_id', 'created_at'],
    :concatenate => [{
      :fields => [
        'first_name', 'last_name', 'customer_number',
        'email', 'phone', 'cell_phone',
        'address', 'co_address', 'post_code', 'locality', 'country'
      ],
      :as => 'person'
    }, {
      :fields => [
        'organization',
        'organization_number',
      ],
      :as => 'organization'
    }],
    :delta => true
  })                         
  
  HUMANIZED_STATUSES = {
    0 => {
      :name  => 'Avvaktande',
      :class => 'pending'
    },
    1 => {
      :name  => 'Avklarad',
      :class => 'completed'
    },
    2 => {
      :name  => 'Dublett/Spam',
      :class => 'deleted'
    },
    3 => {
      :name  => 'Misslyckad',
      :class => 'failed'
    }
  }
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def shipping_name
    "#{shipping_first_name} #{shipping_last_name}"
  end
  
  def name=(names )
    if names and !names.blank?
      names = names.split(" ")
      self.first_name = names.shift
      self.last_name  = names.join(" ") if names
    end
    name
  end
  
  def created_at_formatted_date
    created_at.strftime("%Y-%m-%d")
  end

  def created_at_formatted_time
    created_at.strftime("%H:%M")
  end

  def total_sum_formatted
    total_sum.cents/100
  end
  
  def to_url
    self.class.to_s.underscore
  end

  def payable?
    false
  end
  
  def paid?
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

  # Use cvs fields and convert to latin1 comma seperated string
  def to_cvs_s
    self.class.cvs_fields.collect { |value| "\"#{ self.send(value.to_sym).to_s.to_latin1 }\""}.join(',')
  end
  
  def humanized_status
    HUMANIZED_STATUSES[self.status]
  end
  
  def copy_user_information
    if user
      self.class.user_attribute_matchings.each do |user_key, reg_key|
        unless user_key.is_a?(Array)
          self.send("#{reg_key.to_s}=".to_sym, user.send(user_key)) if self.respond_to?("#{reg_key.to_s}=".to_sym) && self.send(reg_key).blank?
        else
          primary_key, secondary_key = user_key.first, user_key.last
          value = if !user.send(primary_key).blank?
            user.send(primary_key)
          elsif !user.send(secondary_key).blank?
            user.send(secondary_key)
          else
            ''
          end
          self.send("#{reg_key.to_s}=".to_sym, value) if self.respond_to?("#{reg_key.to_s}=".to_sym) && self.send(reg_key).blank?
        end
      end
    end
  end
  
  class << self
    
    def new_from_type(registration_type, attributes = {}, allowed_types = 'all')
      raise SecurityTransgression if allowed_types.is_a?(Array) and not allowed_types.include?(registration_type)
      registration_type.constantize.new(attributes)
    end

    def new_with_user(user = nil, *args)
      returning(self.new) do |r|
        r.user = user
        r.copy_user_information
      end
    end

    def user_attribute_matchings
      {
        :first_name           => :first_name,
        :last_name            => :last_name,
        :cell_phone           => :cell_phone,
        :phone                => :phone,
        :email                => :email
      }
    end

    def average_sum(options = {})
      sql = "select sum(total_sum) / count(*) from registrations where type = '#{self.to_s}'"
      sql += " and created_at between '#{options[:period].first.to_s(:db)}' and '#{options[:period].last.to_s(:db)}' and status = 1" if options[:period]
      Money.new(connection.select_value(sql).to_f.round)
    end

    def total_sum(options = {})
      sql = "select sum(total_sum) from registrations where type = '#{self.to_s}'"
      sql += " and created_at between '#{options[:period].first.to_s(:db)}' and '#{options[:period].last.to_s(:db)}' and status = 1" if options[:period]
      Money.new(connection.select_value(sql).to_f.round)
    end

    def export(period)
      period.blank? ? confirmed.find(:all) : with_period(period).confirmed.find(:all)
    end
    
    def export_count(last_export = false)
      last_export ? count(:conditions => ['created_at > ?', last_export]) : count
    end
    
    def find_for_export(from, through)
      find(:all, :conditions => "registrations.created_at > '#{from.to_s(:db)}' AND registrations.created_at <= '#{through.to_s(:db)}'", :order => 'registrations.created_at')
    end
    
    # Default fields for cvs export, overwrite this in submodels if needed
    def cvs_fields
      [
        :created_at_formatted_date,
        :created_at_formatted_time,
        :first_name,
        :last_name,
        :address,
        :post_code,
        :locality,
        :email,
        :contact_approval,
        :total_sum_formatted,
        :id
      ]
    end
  end

protected

  def generate_public_id
    chars = ("a".."z").to_a + ("1".."9").to_a 
    self.public_id = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{Array.new(32, '').collect{chars[rand(chars.size)]}.join}--")
  end

  def set_current_user
    self.user = User.current if self.user_id.blank?
  end

  def validate
    # errors.add(:type, "has invalid format") if type Registration.valid_registration_types.include?(self.class.to_s)
  end

end
