require 'spec_helper'

describe Discussion do
	before do
    # users
    @john = Factory(:john)
    @jane = Factory(:jane)
		@dapeng = Factory(:dapeng)

		# discussion
		@discussion = Discussion.new(subject: "foo", content: "bar")
		@discussion.user_id = @john.id

    # a discussion with comments
    @discussion_with_comments = Factory(:discussion, user: @john)
    Factory(:comment, discussion: @discussion_with_comments, user: @john)
    @last_comment = Factory(:comment, discussion: @discussion_with_comments, user: @dapeng)

    # a discussion without comments
    @discussion_without_comments = Factory(:discussion, user: @jane)
	end

	subject { @discussion }

	it { should respond_to(:subject) }
	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:display_title) }

	it { should be_valid }

	its(:display_title) { should == @discussion.subject }

	describe "when subject is not present" do
		before { @discussion.subject = "" }

		it { should_not be_valid}
	end

	describe "when subject is too long" do
		before { @discussion.subject = "a" * 51 }

		it { should_not be_valid }
	end

	describe "when content is not present" do
		before { @discussion.content = "" }

		it { should_not be_valid }
	end

	describe "when user_id is not present" do
		before { @discussion.user_id = nil }

		it { should_not be_valid }
	end

  describe "last_update_content of discussion" do
		context "discussion without comments" do
			it "last_update_content should be the same as the content of discussion" do
				@discussion_without_comments.last_update_content.should == @discussion_without_comments.content
			end
		end

		context "discussion with comment" do
			it "last_update_content should be the same as the content of the last comment" do
				@discussion_with_comments.last_update_content.should == @last_comment.content
			end
		end
  end

	describe "last_update_user of discussion" do
		context "discussion without comments" do
			it "last_update_user should be the same as user created the discussion" do
				@discussion_without_comments.last_update_user.should == @jane
			end
		end

		context "discussion with comments" do
			it "last_update_user should be the same as user created the last comment" do
				@discussion_with_comments.last_update_user.should == @dapeng
			end
		end
	end

	describe "last_update_time of discussion" do
		context "discussion without comments" do
			it "last_update_time should be the same as the last update time of discussion" do
				@discussion_without_comments.last_update_time.should == @discussion_without_comments.updated_at
			end

		end

		context "discussion with comments" do
			it "should figure out the specs"

		end
	end

	describe "when touch() method is called" do
		before do
			@discussion.user_id = @john.id
			@discussion.save
		end

		xit "should change the updated_at attribute of discussion" do
			# is there a good way to test timestampe change?
			# expect { @discussion.touch }.to change { @discussion.updated_at }
		end
	end

end
