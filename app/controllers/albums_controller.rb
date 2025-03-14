class AlbumsController < ApplicationController

  def index
    @albums = Album.includes(:user_ratings)
    @albums = @albums.available(current_user) if params[:show_available].present?
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    @albums = @albums.where(label: params[:label]) if params[:label].present?

    @albums = @albums.order("#{params[:sort].presence || 'year, label, catnum'} #{params[:direction]}")

    @albums = @albums.page(params[:page]).per(100)
  end

  def show
    @album = Album.find(params[:id])
  end

  def random
    redirect_to random_albums.first || Album.random.first
  end

  private

  def random_albums
    albums = Album.available(current_user).random
    albums = albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    albums = albums.where.not(id: current_user.user_ratings.pluck(:album_id)) if current_user
    albums
  end

end
