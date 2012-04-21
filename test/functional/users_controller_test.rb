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

end
