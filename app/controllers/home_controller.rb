class HomeController < ApplicationController
  
  def index
    @stats = Album.stats
  end
  
end