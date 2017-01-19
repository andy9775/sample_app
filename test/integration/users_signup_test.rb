require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path
    assert_select 'form[action="/signup"]'
    assert_no_difference 'User.count' do
      post signup_path, params: {
        user: {
          name: '',
          email: 'user@invalid.com',
          password: 'foo',
          password_confirmation: 'bar'
        }
      }
    end

    # assert error explanation is visible
    assert_select 'div[id="error_explanation"]'

    # assert error indicators on labels
    assert_select 'div[class="field_with_errors"]' do
      assert_select 'label[for="user_name"]'
      assert_select 'label[for="user_password"]'
      assert_select 'label[for="user_password_confirmation"]'
    end

    # assert new template is rendered
    assert_template 'users/new'
  end

  test 'valid signup information with account activation' do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: 'Example User',
          email: 'user@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # try to login before activation
    log_in_as user
    assert_not is_logged_in?

    # invalid activation token
    get edit_account_activation_path 'invalid_token', email: user.email
    assert_not is_logged_in?

    # valid token, wrong email
    get edit_account_activation_path user.activation_token, email: 'wrong'
    assert_not is_logged_in?

    # valid activation token
    get edit_account_activation_path user.activation_token, email: user.email
    assert user.reload.activated?
    follow_redirect! # go to the next page
    assert_template 'users/show'
    assert_not flash.empty?
    assert_select 'div[class="alert alert-success"]'
    assert is_logged_in?
  end
end
