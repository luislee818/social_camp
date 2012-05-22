require 'test_helper'

class EventTest < ActiveSupport::TestCase
  NAME_VALID = "Test Event"
  NAME_TOO_LONG = "a" * 101
  START_AT_VALID = "2012/12/21 17:00"
  
  DEFAULT_OPTIONS = {
    name: NAME_VALID,
    start_at: START_AT_VALID
  }
  
  setup do
    @john = users(:john)
  end

  test "event should have name" do
  	event = build_event_for_user(@john, name: nil)

  	assert event.invalid?

  	event.name = "Test event"

  	assert event.valid?
  end

  test "event name should not be more than 100 characters" do
    event = build_event_for_user(@john, name: NAME_TOO_LONG)

    assert event.invalid?
  end

  test "event should have start_at date" do
    event = build_event_for_user(@john, start_at: nil)
    
  	assert event.invalid?

  	event.start_at = START_AT_VALID

  	assert event.valid?
  end

  test "event should have user_id" do
    event = create()

    assert event.invalid?
  end
  
  test "display title should be the same as event name" do
    event = create()
    
    assert_equal NAME_VALID, event.display_title
  end
  
  private
  
    def build_event_for_user(user, options = {})
      user.events.build(DEFAULT_OPTIONS.merge(options))
    end
    
    def create(options = {})
      Event.new(DEFAULT_OPTIONS.merge(options))
    end
end
