# session controller - used to log users in
class SessionsController < ApplicationController
  def new; end

  # create a new session
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      # user exists and is authenticated
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      redirect_back_or @user
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
