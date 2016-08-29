class AlbumSetsController < ApplicationController

  def index
  end

  def show
    @album_set = params[:id] == 'current' ? AlbumSet.last : AlbumSet.find_by(id: params[:id])
    @albums = @album_set.albums.order(:year)
    @user_ratings = current_user.user_ratings.where(album: @albums)
    @user_ratings = @user_ratings.map{|ur| [ur.album_id, ur]}.to_h
  end
end
