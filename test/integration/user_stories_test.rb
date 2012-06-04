require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  setup do
    @john = Factory(:john)
    @discussion_with_comments = Factory(:discussion, user: @john)
  end

  test "user should be redirected to the previously viewed page after sign in" do
    # setting cookie value explicitly to nil will cause it become '' in controller/helper?
    # cookies[:user_id] = nil

    # visit user show page
    get "/discussions/#{@discussion_with_comments.id}"

    # redirect to login page
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template 'new'

    # sign in
    post '/sessions', email: @john.email, password: '1234Abcd'

    # redirect to previous page
    assert_response :redirect
    follow_redirect!
    assert_response :success 
    assert_template 'show', id: @discussion_with_comments.id
  end

  test "user should be redirected to dashboard when visiting root, after sign in" do
    # sign in user
    post '/sessions', email: @john.email, password: '1234Abcd'
    follow_redirect!

    # visit root
    get '/'

    # redirect to dashboard page
    assert_response :redirect
    follow_redirect!
    assert_template 'home'
  end

end
