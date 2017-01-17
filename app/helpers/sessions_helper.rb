# helper module
module SessionsHelper
  # logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # logout the current user
  def log_out
    # session object/class contains methods to mutate the session state.
    # Each session object is available for each request. This means that we can
    # validate or invalidate a session. The session object is built based on the
    # session cookie data sent by the client
    session.delete :user_id
    @current_user = nil
  end

  # Returns the current logged-in user (if any)
  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  # determines if there is a logged in user. Returns true if user is logged in
  def logged_in?
    # method call. Same as self.current_user
    !current_user.nil?
  end
end
