class Admin::CustomAttributesController < ApplicationController
  include Porthos::Admin
  before_filter :find_page

  def update
    @custom_attribute = @page.custom_attributes.find(params[:id])
    @custom_attribute.update_attributes(params[:custom_attribute])
    respond_to do |format|
      format.html { redirect_to edit_admin_page_path(@page) }
    end
  end

  def destroy
    @custom_attribute = @page.custom_attributes.find(params[:id])
    @custom_attribute.destroy
    respond_to do |format|
      format.html { redirect_to edit_admin_page_path(@page) }
    end
  end

protected

  def find_page
    @page = Page.find(params[:page_id])
  end

end