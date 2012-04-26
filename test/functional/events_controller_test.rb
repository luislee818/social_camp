require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    @event = events(:one)
  end

  # Create event-------------------------------------------------

  test "user should signin before visiting create event page" do
    make_sure_user_is_not_signed_in
    get :new
    assert_redirected_to signin_path
  end

  test "new event page title should be 'SocialCamp | Create new event'" do
    user = users(:john)
    sign_in user
    get :new
    assert_select 'title', 'SocialCamp | Create new event'
  end

  test "user should signin before creating event" do
    make_sure_user_is_not_signed_in

    event_name = "foo"
    event_datetime = Time.now
    post :create, event: { name: event_name, start_at: event_datetime }
    
    assert_redirected_to signin_path
  end

  test "event should not be created when name is not provided" do
    user = users(:john)
    sign_in user

    post :create, event: { start_at: Time.now }
    assert_template 'new'
  end

  test "event should not be created when start_at is not provided" do
    user = users(:john)
    sign_in user

    post :create, event: { name: "foo" }
    assert_template 'new'
  end

  test "event should be created when valid info (name and start_at) is provided" do
    user = users(:john)
    sign_in user

    event_name = "foo"
    event_datetime = Time.now
    post :create, event: { name: event_name, start_at: event_datetime }

    assert_redirected_to events_path

    created_event = Event.find_by_name event_name

    refute created_event.nil?
    assert_equal event_datetime.to_i, created_event.start_at.to_i # better way to compare dates?
    assert_equal user, created_event.user
  end

  test "upon successful event creation there should be a changelog" do
    user = users(:john)
    sign_in user

    event_name = "foo"
    event_datetime = Time.now
    post :create, event: { name: event_name, start_at: event_datetime }

    created_event = Event.find_by_name event_name
    changelog = Changelog.of_trackable(created_event).last

    assert_equal created_event, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  # Show event-------------------------------------------------
  test "user should login before viewing an event" do
    make_sure_user_is_not_signed_in
    event = events(:one)
    get :show, id: event.id

    assert_redirected_to signin_path
  end

  test "user can view an event after login" do
    user = users(:john)
    sign_in user

    event = events(:one)
    get :show, id: event.id

    assert_select 'title', 'SocialCamp | View event'
    assert_select 'h1', 'Event details'
  end

  # TODO: how to test a link with text exists?
  # test "event creator should see edit link when viewing an event" do
  #   user = users(:john)
  #   sign_in user

  #   event = events(:one) # created by john
  #   get :show, id: event.id

  # end

  # Show events-------------------------------------------------
  test "user should login before viewing events" do
    make_sure_user_is_not_signed_in
    
    get :index

    assert_redirected_to signin_path
  end

  test "user can view events after login" do
    user = users(:john)
    sign_in user

    get :index

    assert_select 'title', 'SocialCamp | Events'
  end

  # Edit event-------------------------------------------------
  test "user should login before viewing edit event page" do
    make_sure_user_is_not_signed_in
    event = events(:one)
    get :edit, id: event.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of an event created by others" do
    user = users(:jane)
    sign_in user

    event = events(:one) # event created by john
    get :edit, id: event.id

    assert_redirected_to events_path
  end

  test "user can view edit page of an event created by herself" do
    user = users(:john)
    sign_in user

    event = events(:one) # event created by john
    get :edit, id: event.id

    assert_select 'title', 'SocialCamp | Edit event'
  end

  test "admin can view edit page of an event created by others" do
    admin = users(:admin)
    sign_in admin

    event = events(:one) # event created by john
    get :edit, id: event.id

    assert_select 'title', 'SocialCamp | Edit event'
  end

  # Update event-------------------------------------------------
  test "user should login before update an event" do
    make_sure_user_is_not_signed_in
    event = events(:one)
    put :update, id: event.id

    assert_redirected_to signin_path
  end

  test "user cannot update an event created by others" do
    user = users(:jane)
    sign_in user

    event = events(:one) # event created by john
    put :update, id: event.id

    assert_redirected_to events_path
  end

  test "user can update an event created by herself" do
    user = users(:john)
    sign_in user

    event = events(:one) # event created by john
    updated_name = "foobar"
    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to event

    updated_event = Event.find event.id

    assert_equal updated_name, updated_event.name
    assert_equal updated_location, updated_event.location
    assert_equal updated_description, updated_event.description
    assert_equal updated_time.to_i, updated_event.start_at.to_i
    assert_equal user.id, updated_event.user_id
  end

  test "admin can update an event created by another user" do
    admin = users(:admin)
    sign_in admin

    event = events(:two) # event created by john
    updated_name = "foobar"
    updated_location = "Lorem Ipsum"  
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to event

    updated_event = Event.find event.id

    assert_equal updated_name, updated_event.name
    assert_equal updated_location, updated_event.location
    assert_equal updated_description, updated_event.description
    assert_equal updated_time.to_i, updated_event.start_at.to_i
    assert_not_equal admin.id, updated_event.user_id
  end

  test "upon successful event update there should be a changelog" do
    user = users(:john)
    sign_in user

    event = events(:one) # event created by john
    updated_name = "foobar"
    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to event

    updated_event = Event.find event.id
    changelog = Changelog.of_trackable(updated_event).last

    assert_equal updated_event, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  # Destroy event-------------------------------------------------
  test "user should login before destroy an event" do
    make_sure_user_is_not_signed_in
    event = events(:one)
    delete :destroy, id: event.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy an event created by others" do
    user = users(:jane)
    sign_in user

    event = events(:one) # event created by john
    delete :destroy, id: event.id

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id event.id

    refute event_attempted_to_destroy.nil?
  end

  test "user can destroy an event created by herself" do
    user = users(:john)
    sign_in user

    event = events(:one) # event created by john
    delete :destroy, id: event.id

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id event.id

    assert event_attempted_to_destroy.nil?
  end

  test "admin can destroy an event created by another user" do
    admin = users(:admin)
    sign_in admin

    event = events(:one) # event created by john
    delete :destroy, id: event.id

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id event.id

    assert event_attempted_to_destroy.nil?
  end

  test "upon successful event destroy there should be a changelog" do
    user = users(:john)
    sign_in user

    event = events(:one) # event created by john
    final_words = event.final_words
    delete :destroy, id: event.id

    event_attempted_to_destroy = Event.find_by_id event.id

    changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Event', event.id)
                            .last

    assert event_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal user.id, changelog.user_id
  end

  test "upon successful event destroy by admin there should be a changelog" do
    admin = users(:admin)
    sign_in admin

    event = events(:one) # event created by john
    final_words = event.final_words
    delete :destroy, id: event.id

    event_attempted_to_destroy = Event.find_by_id event.id

    changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Event', event.id)
                            .last

    assert event_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal admin.id, changelog.user_id
  end
end
