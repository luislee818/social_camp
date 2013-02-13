require 'spec_helper'

describe "Discussion page" do
	subject { page }

	describe "adding new comment" do
		context "add comment success" do
			it "should clear input text box"

			it "should display success flash"

			context "all comments can fit in one page" do
				it "should display new comment"

				it "should highlight the last comment (testable?)"

			end

			context "all comments would span multiple pages" do
				it "should redirect user to discussion page"
			end
		end

		context "add comment failure" do
			it "should not change value in input text box"

			it "should display error flash"

		end
	end
end
