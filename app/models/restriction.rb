class Restriction < ActiveRecord::Base
  belongs_to :content, :counter_cache => true
  validate :allowed_restriction
  validates_presence_of :mapping_key

  def user_method
    @user_method ||= User.allowed_restrictions[mapping_key.to_sym][:method].to_sym
  end
  
  def negate?
    @negate ||= User.allowed_restrictions[mapping_key.to_sym][:negate]
  end
  
  def require_user?
    @require_user ||= User.allowed_restrictions[mapping_key.to_sym][:require_user]
  end
  
  def allows?(user)
    return false if (require_user? && (!user || user == :false)) || !user.respond_to?(user_method)
    negate? ? !user.send(user_method) : user.send(user_method)
  end
  
  def denies?(user)
    !allows?(user)
  end
  
protected

  def allowed_restriction
    User.allowed_restrictions.keys.include?(mapping_key.to_sym)
  end

end