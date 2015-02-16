class AlbumsController < ApplicationController
  
  def index
    @albums = Album.includes(:user_ratings)
    @albums = params[:show_all].present? ? @albums.of_interest : @albums.downloaded
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    
    @albums = @albums.order("#{params[:sort]} #{params[:direction]} #{'NULLS LAST' if Rails.env.production?}")
    
    @albums = @albums.page(params[:page]).per(100)
  end
  
  def show
    @album = Album.find(params[:id])
  end
  
  def random
    redirect_to Album.of_interest.downloaded.random
  end
end