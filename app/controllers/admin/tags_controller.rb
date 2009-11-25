class Admin::TagsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def search
    @tags = Tag.popular.find(:all, :conditions => ["name LIKE ?", "#{params[:query].downcase.strip}%"])
    respond_to do |format|
      format.js
    end
  end
end