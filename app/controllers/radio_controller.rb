class RadioController < ApplicationController

  def index
  end

  def next_track
    albums = Album.of_interest.uploaded.random
    albums = albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    album = albums.first
    track = album.tracks.sample
    render json: { track: track, album: album }
  end
end
