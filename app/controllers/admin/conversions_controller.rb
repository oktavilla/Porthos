class Admin::ConversionsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def show
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @measure_point = MeasurePoint.find(params[:measure_point_id])
    if params[:type]
      @conversions = @measure_point.conversions.by_type(params[:type]).paginate :page => page, :per_page => per_page
    else
      @conversions = @measure_point.conversions.paginate :page => page, :per_page => per_page
    end
    respond_to do |format|
      format.html {  }
#      format.dp   {  }
    end
  end
end