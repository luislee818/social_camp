require 'spec_helper'

describe Comment do
	before do
		# users
		@john = Factory(:john)

		# discussion
		@discussion = Factory(:discussion)

		# comment
		@comment = Comment.new(content: "foo bar")
		@comment.discussion_id = @discussion.id
		@comment.user_id = @john.id
	end

	subject { @comment }

	its(:display_title) { should == @comment.content }

	describe "when content is not present" do
		before { @comment.content = "" }

		it { should_not be_valid }
	end

	describe "when discussion_id is not present" do
		before { @comment.discussion_id = nil }

		it { should_not be_valid }
	end

	describe "when user_id is not present" do
		before { @comment.user_id = nil }

		it { should_not be_valid }
	end
end
