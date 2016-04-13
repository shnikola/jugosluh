class Api::AlbumsController < ApplicationController
  
  def index
    @albums = Album.where("average_rating IS NOT NULL")
    render json: @albums.except("download_url")
  end

end
