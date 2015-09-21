class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @user_ratings = @user.user_ratings.includes(:album)
    @user_ratings = @user_ratings.order("#{sort_column} #{sort_direction}")
  end

  private

  def sort_column
    params[:sort] || 'created_at'
  end

  def sort_direction
    params[:direction] || 'desc'
  end
end
