class Api::AlbumsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @albums = Album.where("average_rating IS NOT NULL")
    render json: @albums
  end

end
