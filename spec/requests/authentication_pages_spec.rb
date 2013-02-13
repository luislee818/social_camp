require 'spec_helper'

describe "Authentication" do
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_selector('h1', text: 'Sign in') }
		it { should have_selector('title', text: 'Sign in') }
	end

	describe 'sign in' do
		describe 'with invalid info' do
			let(:user) { FactoryGirl.create(:user) }

			before do
				visit signin_path
				click_on "Sign in"
			end

			it { should have_selector('title', text: "Sign in") }
			it { should have_selector('div.alert.alert-error') }

			describe "after visiting another page" do
				before { visit users_path }

				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "with valid info" do
			let(:user) { FactoryGirl.create(:user) }

			before do
				visit signin_path
				fill_in 'Email', with: user.email
				fill_in 'Password', with: user.password
				click_on "Sign in"
			end

			it { should have_link('Discussions', href: discussions_path) }
			it { should have_link('Events', href: events_path) }
			it { should have_link('People', href: users_path) }
			it { should have_link('Progress', href: progress_path) }
			it { should have_link('Profile', href: edit_user_path(user)) }
			it { should have_link('Sign Out', href: signout_path) }
			it { should_not have_link('Sign In', href: signin_path) }

			describe "after signing out" do
				before { click_on "Sign Out" }

				it { should have_link('Sign In', href: signin_path) }
			end
		end
	end

	describe "authorization" do
		describe "for non-signed-in users" do
			describe "when visiting discussions page" do
				before { visit discussions_path }

				it { should have_selector('title', text: 'Sign in') }
			end
			# when attempting to visit a protected page, should redirect to login
		end
	end
	#	authorization
	#		for non-signed-in users
	#		as wrong user
	#		as non-admin user
end
