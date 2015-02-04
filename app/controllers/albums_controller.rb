class AlbumsController < ApplicationController
  
  def index
    @albums = Album.of_interest #.downloaded
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    @albums = @albums.page(params[:page]).per(100)
  end
  
  def show
    @album = Album.find(params[:id])
  end
  
  def random
    #.of_interest -> .downloaded
    redirect_to Album.of_interest.order("RAND()").first # for Postgres use RANDOM()
  end
end