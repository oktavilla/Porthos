class Export < ActiveRecord::Base
  def registrations
    @registrations ||= registration_type.classify.constantize.find_for_export(from, through)
  end
  
  class << self
    def last_export_date_for(registration_type)
      find(:first, :conditions => ['registration_type = ?', registration_type.name], :order => 'created_at DESC').through rescue false
    end
    
    def new_registrations_for(registration_type)
      last_export = Export.last_export_date_for(registration_type)
      last_export ? registration_type.export_count(last_export) : registration_type.export_count
    end
  
    def from_type(registration_type) 
      last_export = Export.last_export_date_for(registration_type) || registration_type.find(:first, :order => 'created_at').created_at - 1.minute
      new( { :registration_type => registration_type.name, :from => last_export, :through => Time.now } )
    end
  end
end
