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

  def shelf
    if params[:new].present?
      session[:shelf] = []
      redirect_to shelf_albums_url and return # Lose the param
    elsif session[:shelf].blank?
      @albums = random_albums.where("image_url IS NOT NULL").first(12)
      session[:shelf] = @albums.map(&:id)
    else
      @albums = Album.where(id: session[:shelf])
    end

    @user_ratings = current_user.user_ratings.where(album: @albums)
    @user_ratings = @user_ratings.map{|ur| [ur.album_id, ur]}.to_h
  end

  private

  def random_albums
    albums = Album.of_interest.uploaded.random
    albums = albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    albums = albums.where.not(id: current_user.user_ratings.pluck(:album_id))
    albums
  end

end
