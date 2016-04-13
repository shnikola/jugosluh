class Api::AlbumsController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def index
    @albums = Album.where("average_rating IS NOT NULL")
    render json: @albums.except("download_url")
  end

end
