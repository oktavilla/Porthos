class Admin::MeasurePointsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'activities'
  
  # GET /measure_points
  # GET /measure_points.xml
  def index
    @measure_points = MeasurePoint.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @measure_points }
      format.csv  { render :layout => false}
    end
  end

  # GET /measure_points/1
  # GET /measure_points/1.xml
  def show
    @measure_point = MeasurePoint.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measure_point }
    end
  end

  # GET /measure_points/new
  # GET /measure_points/new.xml
  def new
    @measure_point = MeasurePoint.new
    @campaign = Campaign.find(params[:campaign_id]) if params[:campaign_id]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @measure_point }
    end
  end

  # GET /measure_points/1/edit
  def edit
    @measure_point = MeasurePoint.find(params[:id])
  end

  # POST /measure_points
  # POST /measure_points.xml
  def create
    @measure_point = MeasurePoint.new(params[:measure_point])
    @measure_point.user = current_user
    
    respond_to do |format|
      if @measure_point.save
        flash[:notice] = 'MeasurePoint was successfully created.'
        format.html { redirect_to admin_campaign_path(@measure_point.campaign) }
        format.xml  { render :xml => @measure_point, :status => :created, :location => @measure_point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @measure_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /measure_points/1
  # PUT /measure_points/1.xml
  def update
    @measure_point = MeasurePoint.find(params[:id])

    respond_to do |format|
      if @measure_point.update_attributes(params[:measure_point])
        flash[:notice] = 'MeasurePoint was successfully updated.'
        format.html { redirect_to admin_campaign_path(@measure_point.campaign) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measure_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /measure_points/1
  # DELETE /measure_points/1.xml
  def destroy
    @measure_point = MeasurePoint.find(params[:id])
    @measure_point.destroy

    respond_to do |format|
      format.html { redirect_to @measure_point.campaign }
      format.xml  { head :ok }
    end
  end
end
