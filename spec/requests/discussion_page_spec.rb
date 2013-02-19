require 'spec_helper'

describe "Discussion page" do
	subject { page }
	let(:discussion_without_comments) { FactoryGirl.create(:discussion) }
	let(:discussion_with_one_page_of_comments) do
		discussion = FactoryGirl.create(:discussion)
		PER_PAGE.times do
			FactoryGirl.create(:comment, discussion: discussion)
		end
		discussion
	end

	before do
		sign_in FactoryGirl.create(:user)
	end

	describe "adding new comment" do
		context "add comment success" do
			comment_content = "Foo bar"

			before do
				visit discussion_path(discussion_without_comments)
				fill_in 'comment_input', with: comment_content
			end

			it "should display success flash", js: true do
				click_on 'Comment'
				page.should have_content 'Comment had been created.'
			end

			it "should clear input text box", js: true do
				click_on 'Comment'
				wait_until { page.has_content? 'Comment had been created.' }
				find_by_id('comment_input').value.should == ""
			end

			it "should create comment" do
				expect { click_on 'Comment' }.to change(discussion_without_comments.comments, :count).by(1)
			end

			context "all comments can fit in one page", js: true do
				it "should display new comment" do
					click_on 'Comment'
					page.should have_xpath("//div/div[@class='comment']/p[text()='#{comment_content}']")
				end

			end

			context "all comments would span multiple pages", js: true do
				it "should not display new comment (redirect user to discussion page)" do
					visit discussion_path(discussion_with_one_page_of_comments)
					fill_in 'comment_input', with: comment_content
					click_on 'Comment'
					page.should_not have_xpath("//div/div[@class='comment']/p[text()='#{comment_content}']")
				end
			end
		end

		context "add comment failure" do
			it "should display error flash", js: true do
				visit discussion_path(discussion_without_comments)
				click_on 'Comment'
				page.should have_content 'Comment was not created, please try again.'
			end

		end
	end
end
