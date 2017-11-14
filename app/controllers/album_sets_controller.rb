class AlbumSetsController < ApplicationController

  def index
  end

  def show
    @album_set = params[:id] == 'current' ? AlbumSet.last : AlbumSet.find_by(id: params[:id])
  end
end
