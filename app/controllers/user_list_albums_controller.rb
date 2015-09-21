class UserListAlbumsController < ApplicationController

  def new
    @album = Album.find(params[:album_id])
    @user_list_album = UserListAlbum.new(album_id: @album.id)
  end

  def create
    @user_list_album = UserListAlbum.new(user_list_album_params)
    if params[:new_list].present?
      list = UserList.create(user_id: current_user.id, name: params[:new_list])
      @user_list_album.user_list = list
    end

    @user_list_album.save if !UserListAlbum.exists?(user_list: @user_list_album.user_list, album: @user_list_album.album)
    redirect_to @user_list_album.album
  end

  def destroy
    @user_list_album = UserListAlbum.find(params[:id])
    @user_list_album.destroy
    redirect_to @user_list_album.user_list
  end

  private

  def user_list_album_params
    params.require(:user_list_album).permit(:album_id, :user_list_id, :note)
  end

end
