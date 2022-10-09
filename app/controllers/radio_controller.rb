class RadioController < ApplicationController

  def index
  end

  def next_track
    albums = Album.uploaded
    albums = albums.from_decade(params[:decade]) if params[:decade].present?
    albums = albums.where(label: params[:label]) if params[:label].present?
    album = albums.random.first
    if album
      render json: { track: album.tracks.sample, album: album }
    else
      render json: {}, status: 404
    end
  end
end
