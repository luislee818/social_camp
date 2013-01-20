require 'spec_helper'

describe Event do
	before do
		@event = Event.new(name: "Learn some new stuff", location: "Anywhere you like",
											 description: "Something really fun", start_at: rand(10).days.ago)
	end

	subject { @event }

	it { should respond_to(:name) }
	it { should respond_to(:location) }
	it { should respond_to(:description) }
	it { should respond_to(:start_at) }
	it { should respond_to(:user_id) }
	it { should respond_to(:display_title) }

	its(:display_title) { should == @event.name }

	describe "accessible attributes" do
		it "should not allow access to user_id" do
			expect do
				Event.create(user_id: 1)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end

	describe "when name is not present" do
		before { @event.name = "" }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @event.name = "a" * 101 }
		it { should_not be_valid }
	end

	describe "when start_at date property is not present" do
		before { @event.start_at = nil }
		it { should_not be_valid }
	end

	describe "when user_id property is not present" do
		before { @event.user_id = nil }
		it { should_not be_valid }
	end
end
