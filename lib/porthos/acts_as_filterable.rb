module Porthos

  module ActsAsFilterable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def acts_as_filterable
        extend ActsAsFilterable::SingletonMethods
      end

      def available_filters
        self.scopes.keys.map { |m| m.to_s }.select do |m|
          m =~ /^filter_/
        end.map { |m| m[7..-1].to_sym }
      end

    end

    module SingletonMethods
    
      def find_with_filter(filters = {})
        filters = filters || {}
        filter_scopes = []
        page = filters.delete(:page) || 1
        per_page = filters.delete(:per_page) || 10
        
        filters.each do |name, value|
          filter_scopes << ["filter_#{name}".to_sym, value] if available_filters.include?(name.to_sym)
        end
        
        filter_scopes.inject(eval(self.to_s)) do |model, scope|
          model.scopes[scope[0]].call(model, scope[1])
        end.paginate(:all, :page => page, :per_page => per_page)
        
      end
    
    end
    
  end
end