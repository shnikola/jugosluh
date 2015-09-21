class UserListsController < ApplicationController
  
  def show
    @user_list = UserList.find(params[:id])
    @albums = @user_list.user_list_albums.joins(:album).includes(album: :user_ratings)
    @albums = @albums.order("#{params[:sort]} #{params[:direction]}") if params[:sort].present?
  end
  
end