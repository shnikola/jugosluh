class SettingsController < ApplicationController
  
  def show
  end

  def update
    session[:whitelist_labels] = params.keys & Label.major
    redirect_to root_url
  end
end
