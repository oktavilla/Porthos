# == Schema Information
# Schema version: 76
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  admin                     :boolean(1)    
#  first_name                :string(255)   
#  last_name                 :string(255)   
#  login                     :string(255)   
#  email                     :string(255)   
#  phone                     :string(255)   
#  cellphone                 :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  avatar_id                 :integer(11)   
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # Virtual attribute for uploaded avatar file
  attr_accessor :file

  has_many :user_roles
  has_many :roles, :through => :user_roles
  
  belongs_to :avatar, :foreign_key => 'avatar_id', :class_name => 'ImageAsset'

  validates_presence_of     :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40, :allow_nil => true
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :login, :case_sensitive => false, :allow_nil => true
  
  before_save :encrypt_password, :save_avatar
  
  def name
    "#{first_name} #{last_name}"
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find(:first, :conditions => ["login = ? or email = ?", login, login]) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def generate_new_password!
    self.password = encrypt(Time.now)[0..6]
    save(false)
  end

  # Asks the resource if we have the rights to create it
  def can_create?(resource)
    resource.can_be_created_by?(self)
  end
  
  # Asks the resource if we have the rights to edit it
  def can_edit?(resource)
    resource.can_be_edited_by?(self)
  end
  
  # Asks the resource if we have the rights to delete it
  def can_destroy?(resource)
    resource.can_be_destroyed_by?(self)
  end

  class << self
    def can_be_edited_by?(user)
      user.admin? || user == self
    end
  
    # Users can not delete them selfs
    def can_be_destroyed_by?(user)
      (user.admin? and user != self) || user == self
    end
  end
  
  def admin?
    has_role?('Admin')
  end
    
  def has_role?(role)
    self.roles.count(:conditions => ['name = ?', role]) > 0
  end

  def add_role(role)
    return if self.has_role?(role)
    self.roles << Role.find_by_name(role)
  end

protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def save_avatar
    if file and file.size.nonzero?
      self.avatar.destroy if self.avatar
      self.avatar = ImageAsset.create(:title => name, :file => file, :private => true)
    end
  end

end
