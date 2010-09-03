class Admin::RegistrationsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def index
    @type = params[:type] || 'Registration'
    page  = params[:page] || 1
    per_page = params[:per_page] || 20

    klass = @type.constantize
    scope = !params[:filter].blank? ? params[:filter].to_sym : :confirmed_or_pending

    conditions = {
      :conditions => ['conversions.measure_point_id = ?', params[:measure_point_id]],
      :include => 'conversion'
    } if params[:measure_point_id]

    @filter = klass.public_filters.include?(scope) ? scope : :confirmed_or_pending
    
    @registrations = klass.send(@filter).paginate({
      :page     => page,
      :per_page => per_page,
      :order    => 'registrations.created_at DESC'
    }.merge(conditions || {}))
  end

  def show
    @registration = Registration.find(params[:id])
    @type = @registration.class.to_s
    @registration_comment = RegistrationComment.new({
      :status => @registration.status,
      :fraud => @registration.fraud
    })
    respond_to do |format|
      format.html
    end
  end

  def edit
    @registration = Registration.find(params[:id])
    @type = @registration.class.to_s
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @registration = Registration.find(params[:id])
    respond_to do |format|
      if @registration.update_attributes(params[@registration.class.to_s.tableize.singularize.to_sym] || params[:registration])
        flash[:notice] = "Dina ändringar är sparade"
        format.html { redirect_to admin_registration_path(:id => @registration, :type => @registration.class.to_s) }
        format.js { render :nothing => true }
      else
        format.html { render :action => 'edit' }
        format.js { render :nothing => true }
      end
    end
  end
  
  def search
    @type = 'Registration'
    @query = params[:query]
    @page  = params[:page] || 1
    @search = Ultrasphinx::Search.new(:query => "#{@query.escape_for_sphinx}", 
                                      :class_names => [@type], 
                                      :page => @page,
                                      :sort_mode => 'descending',
                                      :sort_by => 'created_at')
    @search.run
    respond_to do |format|
      format.html
    end
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
  
  def comment
    @registration_comment = RegistrationComment.new(params[:registration_comment])
    respond_to do |format|
      if @registration_comment.save
        format.html { redirect_to admin_registration_path(:id => @registration_comment.registration, :type => @registration_comment.registration.type, :format => 'html') }
      else
        @type = @registration_comment.registration.class.to_s
        @registration = @registration_comment.registration
        format.html { render :action => 'show'}
      end
    end
  end
  
protected
  def extract_periods
    if params[:period]
      period    = params[:period]
      @period  = [Time.mktime(period.first[:year], period.first[:month], period.first[:day], 00, 00), Time.mktime(period.last[:year], period.last[:month], period.last[:day], 23, 59)]
    end
  end
end
