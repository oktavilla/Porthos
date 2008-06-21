class Admin::RegistrationsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'old_activities'
  
  def index
    @type = params[:type].nil? ? 'Registration' : params[:type]
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @registrations = @type.constantize.paginate :page => page, :per_page => per_page, :order => 'created_at DESC'
  end
  
  def invalid
    @type = params[:type].nil? ? Registration : params[:type]
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @registrations = @type.constantize.respond_to?(:invalid) ? @type.constantize.invalid.paginate(:page => page, :per_page => per_page, :order => 'created_at DESC') : []
  end
  
  def period
    extract_periods
    @type = params[:type].nil? ? Registration : params[:type].constantize
    @registrations = @type.export(@period)
    respond_to do |format|
      format.csv do
        file = render_to_string :template => 'admin/registrations/period', :layout => false
        file_date = @period.blank? ? Time.now.strftime('%Y%m%d'): "#{@period.first.strftime('%Y%m%d')}-#{@period.last.strftime('%Y%m%d')}"
        send_data file, :type => 'text/plain', :disposition => 'attachment', :filename => "#{params[:type]}_#{file_date}.csv"
      end
    end
  end
  
  def show
    @type = params[:type].nil? ? 'Registration' : params[:type]
    @registration = @type.constantize.find(params[:id])
  end
protected
  def extract_periods
    if params[:period]
      period    = params[:period]
      @period  = [Time.mktime(period.first[:year], period.first[:month], period.first[:day], 00, 00), Time.mktime(period.last[:year], period.last[:month], period.last[:day], 23, 59)]
    end
  end
end
