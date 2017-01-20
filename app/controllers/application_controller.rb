class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def logged_in_user
    return if logged_in?
    # if a user is not logged in, save their intended destination and redirect
    # later
    store_location
    flash[:danger] = 'Please log in'
    redirect_to login_url
  end
end
