# session controller
class SessionsController < ApplicationController
  def new; end

  # create a new session
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # user exists and is authenticated
      log_in user
      remember user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  # end a session
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
