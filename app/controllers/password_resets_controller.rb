class PasswordResetsController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset information'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def edit; end

  def update
    # user model validates method allows for nil passwords when editing.
    # Therefore, we need to explicitly check if the password is empty when the
    # user resets it
    if params[:user][:password].empty? # must explicitly check if pass is empty
      @user.errors.add(:password, 'can\'t be empty')
      render 'edit'
    elsif @user.update_attributes user_params # validation passes
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = 'Password has been reset'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # finds a user by email via params
  def set_user
    @user = User.find_by email: params[:email]
  end

  # checks if a user is valid
  def valid_user
    unless @user &&
           @user.activated? &&
           # params[:id] is the reset token passed via the URL
           @user.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  # check if the password reset link is expired
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = 'Password reset has expired!'
    redirect_to new_password_reset_url
  end
end
