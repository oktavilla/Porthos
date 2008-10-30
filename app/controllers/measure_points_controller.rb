class MeasurePointsController < ApplicationController
  def click
    measure_point = MeasurePoint.find_by_public_id(params[:id].upcase)
    if measure_point
      measure_point.increment!(:num_clicks)
      session[:measure_point] = measure_point.id
    end
    if params[:target] and params[:target] =~ /^\/([a-z0-9\/\-\?\=]+)$/i
      redirect_to params[:target]
    else
      redirect_to '/'
    end
  end
end