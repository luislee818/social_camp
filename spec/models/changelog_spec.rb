require 'spec_helper'

describe Changelog do
	before do
    # users
    @john = Factory(:john)

    # a discussion with comments
    @discussion = Factory(:discussion, user: @john)

		# changelog
		@changelog = Changelog.new
		@changelog.user_id = @john.id
		@changelog.action_type_id = ActionType::ADD
		@changelog.trackable = @discussion
	end

	subject { @changelog }

	it { should respond_to(:user_id) }
	it { should respond_to(:action_type_id) }
	it { should respond_to(:trackable_id) }
	it { should respond_to(:trackable_type) }

	it { should be_valid }

	describe "when user_id is not present" do
		before { @changelog.user_id = nil }

		it { should_not be_valid }
	end

	describe "when action_type_id is not present" do
		before { @changelog.action_type_id = nil }

		it { should_not be_valid }
	end

	describe "when trackable is not present" do
		before { @changelog.trackable = nil }

		it { should_not be_valid }
	end
end
