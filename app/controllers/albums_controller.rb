class AlbumsController < ApplicationController
  
  def index
    @albums = params[:show_all].present? ? Album.of_interest : Album.downloaded
    @albums = @albums.includes(:user_ratings)
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    
    @albums = params[:decade].present? ? @albums.order("year, label, catnum") : @albums.order("label, catnum")
    
    @albums = @albums.page(params[:page]).per(100)
  end
  
  def show
    @album = Album.find(params[:id])
  end
  
  def random
    redirect_to Album.of_interest.downloaded.random
  end
end