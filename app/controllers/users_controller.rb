class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    @user_ratings = @user.user_ratings.includes(:album)
    @user_ratings = @user_ratings.order("#{params[:sort]} #{params[:direction]}") if params[:sort].present?

  end
end