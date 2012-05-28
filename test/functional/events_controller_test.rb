require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  NAME_VALID = "foo"
  START_AT_VALID = Time.now

  DEFAULT_OPTIONS = {
    name: NAME_VALID,
    start_at: START_AT_VALID
  }

  setup do
    # users
    @john = Factory(:john)
    @jane = Factory(:jane)
    @admin = Factory(:admin)

    # events
    @event = Factory(:event, user: @john)
    @event_without_location = Factory(:event, location: nil)
    @event_without_description = Factory(:event, description: nil)
    Factory(:event, start_at: Time.now + 2.days, user: @john)
  end

  # Show events-------------------------------------------------
  test "user should sign in before viewing events" do
    make_sure_user_is_not_signed_in
    
    get :index

    assert_redirected_to signin_path
  end

  test "user can view events after sign in" do
    sign_in @john

    get :index

    assert_template 'index'
    assert_select 'title', 'SocialCamp | Events'
    assert_select 'div#events', count: 1
  end

  test "events page should show past events and upcoming events" do
    sign_in @john

    get :index

    assert_response :success
    upcoming_events = assigns(:upcoming_events)
    assert upcoming_events.size > 0
    assert_select 'div#upcoming-events', count: 1
    assert_select 'div#upcoming-events p[id *= event-]', count: upcoming_events.size

    past_events = assigns(:past_events)
    assert past_events.size > 0
    assert_select 'div#past-events', count: 1
    assert_select 'div#past-events p[id *= event-]', count: past_events.size
  end

  test "events page should display links for 'new event' and 'rss'" do
    sign_in @john

    get :index

    assert_response :success
    assert_select 'a#event-new-link', count: 1
    assert_select 'span#rss', count: 1
  end

  # Create event-------------------------------------------------

  test "user should signin before visiting create event page" do
    make_sure_user_is_not_signed_in

    get :new

    assert_redirected_to signin_path
  end

  test "new event page title should be 'SocialCamp | Create new event'" do
    sign_in @john

    get :new

    assert_template 'new'
    assert_select 'title', 'SocialCamp | Create new event'
    assert_select 'div#event-new', count: 1
    assert_select 'a#events-link', count: 1
  end

  test "user should signin before creating event" do
    make_sure_user_is_not_signed_in

    post :create, event: DEFAULT_OPTIONS
    
    assert_redirected_to signin_path
  end

  test "event should not be created when name is not provided" do
    sign_in @john

    post :create, event: DEFAULT_OPTIONS.merge({ name: nil })

    event = Event.find_by_start_at DEFAULT_OPTIONS[:start_at].to_i
    assert event.nil?
    assert_template 'new'
  end

  test "event should not be created when start_at is not provided" do
    sign_in @john

    post :create, event: DEFAULT_OPTIONS.merge({ start_at: nil })

    event = Event.find_by_name DEFAULT_OPTIONS[:name]
    assert event.nil?
    assert_template 'new'
  end

  test "event should be created when valid info (name and start_at) is provided" do
    sign_in @john

    post :create, event: DEFAULT_OPTIONS

    assert_redirected_to events_path

    created_event = Event.find_by_name DEFAULT_OPTIONS[:name]

    refute created_event.nil?
    assert_equal DEFAULT_OPTIONS[:start_at].to_i, created_event.start_at.to_i # better way to compare dates?
    assert_equal @john, created_event.user
  end

  test "upon successful event creation there should be a changelog" do
    sign_in @john

    post :create, event: DEFAULT_OPTIONS

    created_event = Event.find_by_name DEFAULT_OPTIONS[:name]
    changelog = Changelog.of_trackable(created_event).last

    assert_equal created_event, changelog.trackable
    assert_equal ActionType::ADD, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  # Show event-------------------------------------------------
  test "user should sign in before viewing an event" do
    make_sure_user_is_not_signed_in

    get :show, id: @event.id

    assert_redirected_to signin_path
  end

  test "user can view an event after sign in" do
    sign_in @john

    get :show, id: @event.id

    assert_select 'title', 'SocialCamp | View event'
    assert_select 'div#event-show', count: 1
    assert_select 'a#events-link', count: 1
  end

  test "event with name, location, description, start_at should show all details" do
    sign_in @john

    get :show, id: @event.id

    assert_select 'div#event-show div#event-name', count: 1
    assert_select 'div#event-show div#event-location', count: 1
    assert_select 'div#event-show div#event-description', count: 1
    assert_select 'div#event-show div#event-start_at', count: 1
    assert_select 'div#event-show div#event-history', count: 1
  end

  test "event without location should not show location" do
    sign_in @john

    get :show, id: @event_without_location.id

    assert_select 'div#event-show div#event-location', false
  end

  test "event without description should not show description" do
    sign_in @john

    get :show, id: @event_without_description.id

    assert_select 'div#event-show div#event-description', false
  end

  test "user who created the event should see links for 'edit' and 'delete' in show event page" do
    sign_in @john

    get :show, id: @event.id # created by john

    assert_select 'a#event-edit-link', count: 1
    assert_select 'a#event-delete-link', count: 1
  end

  test "admin should see links for 'edit' and 'delete' in show event page" do
    sign_in @admin

    get :show, id: @event.id # created by john

    assert_select 'a#event-edit-link', count: 1
    assert_select 'a#event-delete-link', count: 1
  end

  test "regular user should not see links for 'edit' and 'delete' in show event page" do
    sign_in @jane

    get :show, id: @event.id # created by john

    assert_select 'a#event-edit-link', false
    assert_select 'a#event-delete-link', false
  end

  # Edit event-------------------------------------------------

  test "user should sign in before viewing edit event page" do
    make_sure_user_is_not_signed_in

    get :edit, id: @event.id

    assert_redirected_to signin_path
  end

  test "user cannot view edit page of an event created by others" do
    sign_in @jane

    get :edit, id: @event.id # created by john

    assert_redirected_to events_path
  end

  test "user can view edit page of an event created by herself" do
    sign_in @john

    get :edit, id: @event.id # created by john

    assert_select 'title', 'SocialCamp | Edit event'
    assert_select 'div#event-edit', count: 1
    assert_select 'a#events-link', count: 1
    assert_select 'a#event-delete-link', count: 1
  end

  test "admin can view edit page of an event created by others" do
    sign_in @admin

    get :edit, id: @event.id # created by john

    assert_select 'title', 'SocialCamp | Edit event'
    assert_select 'div#event-edit', count: 1
    assert_select 'a#events-link', count: 1
    assert_select 'a#event-delete-link', count: 1
  end

  # Update event-------------------------------------------------

  test "user should sign in before updating an event" do
    make_sure_user_is_not_signed_in

    put :update, id: @event.id

    assert_redirected_to signin_path
  end

  test "user cannot update an event created by others" do
    sign_in @jane

    put :update, id: @event.id # created by john

    assert_redirected_to events_path
  end

  test "event should not be updated when name is not provided" do
    sign_in @john

    old_name = @event.name

    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: @event.id, event: { name: nil, location: updated_location,
                 description: updated_description, start_at: updated_time }

    event = Event.find @event.id
    assert_equal old_name, event.name
    assert_template 'edit'
  end

  test "event should not be updated when start_at is not provided" do
    sign_in @john

    old_time = @event.start_at

    updated_name = "foobar"
    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    put :update, id: @event.id, event: { name: nil, location: updated_location,
                 description: updated_description, start_at: nil }

    event = Event.find @event.id
    assert_equal old_time, event.start_at
    assert_template 'edit'
  end

  test "user can update an event created by herself" do
    sign_in @john

    updated_name = "foobar"
    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: @event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to @event

    updated_event = Event.find @event.id

    assert_equal updated_name, updated_event.name
    assert_equal updated_location, updated_event.location
    assert_equal updated_description, updated_event.description
    assert_equal updated_time.to_i, updated_event.start_at.to_i
    assert_equal @john.id, updated_event.user_id
  end

  test "admin can update an event created by another user" do
    sign_in @admin

    updated_name = "foobar"
    updated_location = "Lorem Ipsum"  
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: @event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to @event

    updated_event = Event.find @event.id

    assert_equal updated_name, updated_event.name
    assert_equal updated_location, updated_event.location
    assert_equal updated_description, updated_event.description
    assert_equal updated_time.to_i, updated_event.start_at.to_i
    assert_not_equal @admin.id, updated_event.user_id
  end

  test "upon successful event update there should be a changelog" do
    sign_in @john

    updated_name = "foobar"
    updated_location = "Lorem Ipsum"
    updated_description = "More Lorem Ipsum"
    updated_time = Time.now
    put :update, id: @event.id, event: { name: updated_name, location: updated_location,
                 description: updated_description, start_at: updated_time }

    assert_redirected_to @event

    updated_event = Event.find @event.id
    changelog = Changelog.of_trackable(updated_event).last

    assert_equal updated_event, changelog.trackable
    assert_equal ActionType::UPDATE, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  # Destroy event-------------------------------------------------

  test "user should sign in before destroy an event" do
    make_sure_user_is_not_signed_in

    delete :destroy, id: @event.id

    assert_redirected_to signin_path
  end

  test "user cannot destroy an event created by others" do
    sign_in @jane

    delete :destroy, id: @event.id # created by john

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id @event.id

    refute event_attempted_to_destroy.nil?
  end

  test "user can destroy an event created by herself" do
    sign_in @john

    delete :destroy, id: @event.id # created by john

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id @event.id

    assert event_attempted_to_destroy.nil?
  end

  test "admin can destroy an event created by another user" do
    sign_in @admin

    delete :destroy, id: @event.id

    assert_redirected_to events_path

    event_attempted_to_destroy = Event.find_by_id @event.id

    assert event_attempted_to_destroy.nil?
  end

  test "upon successful event destroy there should be a changelog" do
    sign_in @john

    final_words = @event.final_words
    delete :destroy, id: @event.id

    event_attempted_to_destroy = Event.find_by_id @event.id

    changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Event', @event.id)
                            .last

    assert event_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @john.id, changelog.user_id
  end

  test "upon successful event destroy by admin there should be a changelog" do
    sign_in @admin

    final_words = @event.final_words
    delete :destroy, id: @event.id

    event_attempted_to_destroy = Event.find_by_id @event.id

    changelog = Changelog.find_all_by_trackable_type_and_trackable_id(
                            'Event', @event.id)
                            .last

    assert event_attempted_to_destroy.nil?
    assert_equal final_words, changelog.destroyed_content_summary
    assert_equal ActionType::DESTROY, changelog.action_type_id
    assert_equal @admin.id, changelog.user_id
  end
end
