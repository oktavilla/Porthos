# == Schema Information
# Schema version: 76
#
# Table name: content_modules
#
#  id                     :integer(11)   not null, primary key
#  name                   :string(255)   
#  template               :string(255)   
#  created_at             :datetime      
#  updated_at             :datetime      
#  available_in_page_type :string(255)   
#

class ContentModule < ActiveRecord::Base
  validates_presence_of :name, :template, :available_in_page_type

  def available_templates
    @available_templates ||= self.class.find_available_templates
  end
  
  def available_page_types
    self.class.available_page_types
  end

  class << self

    def can_be_edited_by?(user)
      user.has_role?('SiteAdmin')
    end

    def can_be_created_by?(user)
      user.has_role?('SiteAdmin')
    end

    def can_be_destroyed_by?(user)
      user.has_role?('SiteAdmin')
    end
    
    def available_page_types
      ['Page', 'PageCollection']
    end
    
    def find_available_templates
      [RAILS_ROOT + '/app/views/pages/contents/modules', File.dirname(__FILE__) + '/../views/pages/contents/modules'].collect do |path|
        Dir.entries(path).reject { |entry| File.directory?(File.join(path, entry)) }.collect { |file| File.basename(file, '.html.erb').gsub(/^\_/, '') } if File.exists? path
      end.flatten.compact.uniq.sort
    end
  end

end
