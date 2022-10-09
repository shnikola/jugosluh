class AlbumIssuesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @issues = AlbumIssue.includes(:user, :album)
  end

  def new
    @album = Album.find(params[:album_id])
  end

  def create
    @issue = current_user.album_issues.create(issue_params)
    redirect_to album_url(@issue.album_id)
  end

  private

  def issue_params
    params.require(:album_issue).permit(:album_id, :message)
  end

end
