require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unseccesful edit' do
    log_in_as @user
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }
    assert_template 'users/edit'
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to edit_user_url(@user)

    # we can follow the requested redirect and assert the rendered template
    # not necessary since we're not doing anything with the template - a patch
    # request is sent directly without interacting with the rendered html
    # follow_redirect!
    # assert_template 'users/edit'
    assert_nil session[:forwarding_url] # ensure the forwarding url is removed
    name = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: { user: { name: name,
                                              email: email,
                                              password: '',
                                              password_confirmation: '' } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload # need to reload the use to fetch updated info from DB
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
