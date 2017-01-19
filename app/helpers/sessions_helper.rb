# helper module
module SessionsHelper
  # logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # remembers to user for a permanent session
  def remember(user)
    # create a new remember token and save to DB
    user.remember
    # assign user id to cookie and sign it
    cookies.permanent.signed[:user_id] = user.id
    # add remember token to the cookie. **Permanent** sets it for 20 years
    cookies.permanent[:remember_token] = user.remember_token
  end

  # forgets a persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # logout the current user
  def log_out
    # session object/class contains methods to mutate the session state.
    # Each session object is available for each request. This means that we can
    # validate or invalidate a session. The session object is built based on the
    # session cookie data sent by the client
    forget current_user # method. same as self.current_user
    session.delete :user_id
    @current_user = nil
  end

  # Returns the current logged-in user (if any)
  def current_user
    # if short session exists, use that
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id]) # long term session cookie
      user = User.find_by(id: user_id)
      # is valid?
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user # log user in and set a session
        @current_user = user
      end
    end
    # else nothing exists for the user id or the long term cookie is invalid
  end

  # determines if there is a logged in user. Returns true if user is logged in
  def logged_in?
    # method call. Same as self.current_user
    !current_user.nil?
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
