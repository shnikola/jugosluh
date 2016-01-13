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
    scope = Album.of_interest.uploaded
    scope = scope.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    redirect_to scope.random
  end
end
