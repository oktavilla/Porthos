require 'fileutils' 
class AssetsController < ApplicationController
  
  skip_before_filter :remember_uri
  
  # GET /assets/1
  # GET /assets/1.xml
  def show
    return head(:not_found) unless @asset = Asset.find_by_file_name(params[:id])
    respond_to do |format|
      format.html { render :action => "show" }
      if params[:format]
        asset_type = @asset.extname.to_sym
        begin
          format.send(asset_type) do
            if params[:size] and @asset.image?
              return send_image(@asset, params[:size])
            elsif @asset.movie?
              return send_movie(@asset)
            else
              return send_file(@asset.path, :filename => @asset.full_name, :type => @asset.mime_type, :disposition => 'inline')
            end
          end
        rescue NameError
          return send_file(@asset.path, :filename => @asset.full_name, :type => @asset.mime_type, :disposition => 'attachment')
        end
      end
    end
  end

protected

  def send_image(image, size)
    path = image.version_path(size)
    unless File.exists?(path)
      if (params[:token] && image.resize_token(size) == params[:token]) || logged_in?
        image.resize(:size => size, :quality => 95) 
        if File.exists?(path)
          send_file(path, :filename => image.full_name, :disposition => 'inline', :type => image.mime_type) and return
        end
      end
    end
    return head(:not_found)
  end

  def send_movie(movie)
    begin
      send_file(movie.public_path, :disposition => 'inline', :type => movie.mime_type) if movie.create_public_path
    rescue
      return head(:not_found)
    end
  end

end
