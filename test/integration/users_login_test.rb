require 'test_helper'

# Test user login/logout logic
class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # the users method call refers to the users.yml file and takes an argument
    # for the required key in the yml file
    @user = users(:michael)
  end

  test 'login with valid information followed by logout' do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
    assert_redirected_to @user # redirect to user profile page
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # simulate a user clicking logout in a second window
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: '', password: '' } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'login with remembering' do
    # log_in_as helper posts to /login which is handled by
    # session_controller.create. The create method creates an instance of @user
    # which we can access using assigns. We fetch the remember_token from the
    # user and compare it to the value set in the cookies
    log_in_as @user, remember_me: '1'
    # cookie should be set to the virtual attribute remember_token
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test 'login without remembering' do
    # login to set the cookie
    log_in_as @user, remember_me: '1'
    # Login again to verify the cookie is deleted
    log_in_as @user, remember_me: '0'
    assert_empty cookies['remember_token']
  end
end
