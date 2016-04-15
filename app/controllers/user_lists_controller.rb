class UserListsController < ApplicationController
  
  def index
    @user_lists = UserList.includes(:user)
  end
  
  def show
    @user_list = UserList.includes(user_list_albums: :album).find(params[:id])
  end
  
end
