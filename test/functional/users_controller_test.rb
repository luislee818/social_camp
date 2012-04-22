require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "show page should display user name in h1" do
    get :show, id: @user
    assert_response :success
    assert_select 'h1', @user.name
  end
  
  test "user should sign up with valid information" do
    post :create, user: { name: "foo", email: "bar@nltechdev.com", 
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    refute user.nil?
    assert_redirected_to user
    assert_equal user.id, cookies[:user_id]
  end
  
  # TODO: Add all failure cases? Duplicating tests in unit tests?
  test "user should not sign up with invalid information" do
    post :create, user: { name: "", email: "bar@nltechdev.com", 
                          password: "secret", password_confirmation: "secret" }
    user = User.find_by_name "foo"
    assert user.nil?
    assert_template 'new'
  end

end
