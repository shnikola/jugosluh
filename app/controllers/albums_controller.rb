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
    @albums = Album.of_interest.uploaded.random
    @albums = @albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    @albums = @albums.where.not(id: current_user.user_ratings.pluck(:album_id))
    redirect_to @albums.first
  end
  
  def random_showcase
    @albums = Album.of_interest.uploaded.random
    @albums = @albums.where(label: session[:whitelist_labels]) if session[:whitelist_labels].present?
    @albums = @albums.where.not(id: current_user.user_ratings.pluck(:album_id))
    @albums = @albums.where("image_url IS NOT NULL").first(12)
  end
  
  def tracks
    @album = Album.find(params[:id])
    @tracks = AlbumTracks.fetch(@album)
    if current_user.id == 2 # Proxy for Pero
      @tracks.each {|t| t[:url] = "http://ru2.gsr.awhoer.net/home287/cmd?urlText=#{t[:url]}" }
    end
    render json: @tracks
  end
  
end
