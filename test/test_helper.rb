ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-json'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
]
SimpleCov.start 'rails' # load before application is required
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

# test helpers
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
  # order.
  fixtures :all
  include ApplicationHelper
  # Add more helper methods to be used by all tests here...

  # checks if a user is logged in based on the session data
  def is_logged_in?
    !session[:user_id].nil?
  end

  # login as a particular user
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end
