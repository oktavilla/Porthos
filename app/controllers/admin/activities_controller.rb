class Admin::ActivitiesController < ApplicationController
  include Porthos::Admin
  before_filter :login_required, :extract_periods
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @type = params[:type] ? params[:type].classify.constantize : false
    respond_to do |format|
      format.html 
    end
  end

protected
  def extract_periods
    if params[:periods]
      first_period  = params[:periods][:first]
      second_period = params[:periods][:second]
      @first_period  = [Time.mktime(first_period.first[:year], first_period.first[:month], first_period.first[:day], 00, 00), Time.mktime(first_period.last[:year], first_period.last[:month], first_period.last[:day], 23, 59)]
      @second_period = [Time.mktime(second_period.first[:year], second_period.first[:month], second_period.first[:day], 00, 00), Time.mktime(second_period.last[:year], second_period.last[:month], second_period.last[:day], 23, 59)]
    else
      now = Time.now
      @first_period  = [now.at_beginning_of_month, now.at_end_of_month]
      @second_period = [now.last_year.at_beginning_of_month, now.last_year.at_end_of_month]
    end
  end
end
