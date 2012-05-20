require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  test "should get discussions feed" do
    get :discussions, format: 'rss'
    assert_response :success
  end
  
  test "should get event updates feed" do
    get :events, format: 'rss'
    assert_response :success
  end
  
  test "should get progresses feed" do
    get :progresses, format: 'rss'
    assert_response :success
  end

end
