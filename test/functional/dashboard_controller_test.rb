require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup do
    # user
    @john = Factory(:john)
    
    # discussions
    5.times do |i|
      Factory(:discussion, user: @john)      
    end
    
    # events
    5.times do |i|
      Factory(:event, user: @john)
    end
  end

  test "user should signin before viewing dashboard page" do
    make_sure_user_is_not_signed_in
    
    get :home
    
    assert_redirected_to signin_path
  end

  test "user should be able to view dashboard page after sign in" do
    sign_in @john

    get :home

    assert_select 'title', 'SocialCamp | Dashboard'
    # discussions
    assert_select 'div#discussions', count: 1
    assert_select 'div#discussions tr[id *= discussion-]', count: assigns(:discussions).size
    assert_select 'a#discussions-link', count: 1
    # upcoming events
    assert_select 'div#upcoming_events', count: 1
    assert_select 'div#upcoming_events tr[id *= event-]', count: assigns(:upcoming_events).size
    assert_select 'a#events-link', count: 1
  end
  
end
