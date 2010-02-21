class MeasurePointsController < ApplicationController
  def click
    if measure_point = MeasurePoint.find_by_public_id(params[:id].upcase)
      measure_point.increment!(:num_clicks)
      session[:measure_point] = measure_point.id
    end
    if params[:target] and params[:target][0...1] == '/'
      target_params = params.dup.delete_if do |key, value|
        %w(controller action id target).include?(key.to_s)
      end.to_query
      if target_params.blank?
        redirect_to params[:target]
      else
        redirect_to [params[:target], target_params].join((params[:target].include?('?') ? '&' : '?'))
      end
    else
      redirect_to '/'
    end
  end
end