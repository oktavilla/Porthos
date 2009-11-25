class Admin::ExportsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def index
    registration_type = params[:registration_type].classify.constantize
    @export = Export.from_type(registration_type)
    if @export.registrations.size > 0
      @export.save 
      template = "admin/exports/#{@export.registration_type.tableize}"
      respond_to do |format|
        format.dp do
          file = render_to_string :template => template
          send_data file, :type => 'text/plain; charset=ISO-8859-1', :disposition => 'attachment', :filename => "#{@export.registration_type.tableize}_#{@export.from.strftime("%Y%m%d")}-#{@export.through.strftime("%Y%m%d")}.#{params[:format]}"
        end
        format.html { render :template => "admin/exports/#{registration_type.name.tableize}" }
      end
    else
      render :template => "admin/exports/nothing_to_export.html.erb"
    end
  end
  
  def show
    @export = Export.find(params[:id])
    template = "admin/exports/#{@export.registration_type.tableize}"
    respond_to do |format|
      format.dp do
        file = render_to_string :template => template
        send_data file, :type => 'text/plain; charset=ISO-8859-1', :disposition => 'attachment', :filename => "#{@export.registration_type.tableize}_#{@export.from.strftime("%Y%m%d")}-#{@export.through.strftime("%Y%m%d")}.#{params[:format]}"
      end
      format.html { render :template => "admin/exports/#{@export.registration_type.tableize}" }
    end
  end
protected
  def make_downloadable
    response.headers['Content-Disposition'] = "attachment; filename=\"#{@export.registration_type.tableize}_#{@export.from.strftime("%Y%m%d")}-#{@export.through.strftime("%Y%m%d")}.#{params[:format]}\""
  end
end
