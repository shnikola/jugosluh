class AlbumsController < ApplicationController

  def index
    @albums = Album.includes(:user_ratings)
    @albums = params[:show_all].present? ? @albums.of_interest : @albums.uploaded
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    @albums = @albums.where(label: params[:label]) if params[:label].present?

    @albums = @albums.order("#{params[:sort]} #{params[:direction]}") if params[:sort].present?

    @albums = @albums.page(params[:page]).per(100)
  end

  def show
    @album = Album.find(params[:id])
  end

  def random
    redirect_to random_albums.first
  end

  def covers
    @albums = Album.of_interest.uploaded
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    @albums = @albums.random.first(50)
  end


  private

  def random_albums
    albums = Album.of_interest.uploaded.random
    albums = albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    albums = albums.where.not(id: current_user.user_ratings.pluck(:album_id))
    albums
  end

end
