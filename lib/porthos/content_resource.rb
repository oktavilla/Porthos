module Porthos
  module ContentResource

    def self.included(base)
      base.cattr_accessor :view_paths
      base.class_eval <<-EOF
        self.view_paths = {
          :admin  => "/admin/contents/#{base.to_s.underscore.pluralize}/#{self.to_s.underscore}.html.erb",
          :new    => "/admin/contents/#{base.to_s.underscore.pluralize}/new",
          :edit   => "/admin/contents/#{base.to_s.underscore.pluralize}/edit",
          :public => "/pages/contents/#{base.to_s.underscore}.html.erb"
        }
      EOF
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods

      def view_path(type)
        self.class.view_path(type)
      end

    end

    module ClassMethods
      
      def view_path(type)
        view_paths[type.to_sym]
      end
      
    end
  end
end