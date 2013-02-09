require 'spec_helper'

describe "User pages" do

  subject { page }

	describe "index" do

		before do
			sign_in FactoryGirl.create(:user)
			FactoryGirl.create(:john)
			FactoryGirl.create(:jane)
			visit users_path
		end

		it { should have_selector('title', text: "People") }

		describe "pagination" do

			before(:all) { 30.times { FactoryGirl.create(:user) } }
			after(:all) { User.delete_all }

			let(:first_page) { User.paginate(page: 1) }
			let(:second_page) { User.paginate(page: 2) }

			it { should have_link('Next') }

			it "should have >2</a> in html" do
				subject.html.should match('>2</a>')
			end

			it "should list each user" do
				User.all[0..2].each do |user|
					page.should have_selector('li', text: user.name)
				end
			end

			it "should list the first page of users" do
				first_page.each do |user|
					page.should have_selector('li', text: user.name)
				end
			end

			it "should not list the second page of users" do
				second_page.each do |user|
					page.should_not have_selector('li', text: user.name)
				end
			end

			describe "displaying the second page" do
				before { visit users_path(page: 2) }

				it "should list the second page of users" do
					second_page.each do |user|
						page.should have_selector('li', text: user.name)
					end
				end
			end
		end
	end

  describe "signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: 'Sign up') }
    # not sure why app/helpers/application_helper is not mixed in
    it { should have_selector('title', text: 'SocialCamp | Sign up') }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "error messages" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "example@nltechdev.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }

        let(:user) { User.find_by_email('example@nltechdev.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome on board') }
        it { should have_link('Sign Out') }
      end
    end
  end
end
