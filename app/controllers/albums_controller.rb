class AlbumsController < ApplicationController
  
  def index
    @albums = Album.of_interest
    @albums = @albums.downloaded if params[:downloaded].present?
    @albums = @albums.search(params[:search]) if params[:search].present?
    @albums = @albums.from_decade(params[:decade]) if params[:decade].present?
    @albums = @albums.order("label, catnum")
    @albums = @albums.page(params[:page]).per(100)
  end
  
  def show
    @album = Album.find(params[:id])
  end
  
  def random
    redirect_to Album.of_interest.downloaded.random
  end
end