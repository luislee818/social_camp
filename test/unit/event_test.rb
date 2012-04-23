require 'test_helper'

class EventTest < ActiveSupport::TestCase
  NAME_VALID = "Test Event"
  START_AT_VALID = "2012/12/21 17:00"

  # test "the truth" do
  #   assert true
  # end
  test "event should have name" do
  	event = Event.new(start_at: START_AT_VALID)

  	assert event.invalid?

  	event.name = "Test event"

  	assert event.valid?
  end

  test "event should have start_at date" do
  	event = Event.new(name: NAME_VALID)

  	assert event.invalid?

  	event.start_at = START_AT_VALID

  	assert event.valid?
  end
end
