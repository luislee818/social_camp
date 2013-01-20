require 'spec_helper'

describe User do
  before do
    @user = User.new(name: "Example User", email: "user@nltechdev.com",
                     password: "Abc1234", password_confirmation: "Abc1234")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
	it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

	it { should be_valid }
	it { should_not be_admin }

	describe "accessible attributes" do
		it "should not allow access to admin" do
			expect do
				User.new(admin: true)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end

	describe "with admin attribute set to 'true'" do
		before do
			@user.save!
			@user.toggle!(:admin)
		end

		it { should be_admin }
	end

	describe "when name is not present" do
		before { @user.name = '' }
		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @user.email = "" }
		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "a" * 21 }
		it { should_not be_valid }
	end

	describe "when email format is invalid" do
		it "should be invalid" do
			invalid_emails = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]

			invalid_emails.each do |invalid_email|
				@user.email = invalid_email
				@user.should_not be_valid
			end
		end
	end

	describe "when email format is valid" do
		it "should be valid" do
			valid_emails = %w[abc@nltechdev.com foo@nltechdev.com dpli@NLTechDev.com]

			valid_emails.each do |valid_email|
				@user.email = valid_email
				@user.should be_valid
			end
		end
	end

	describe "when user name is already taken" do
		context "names have the exact same cases" do
			before do
				user_with_same_name = @user.dup
				user_with_same_name.email.prepend "foo"  # so emails will not be the same
				user_with_same_name.save
			end

			it { should_not be_valid }
		end

		context "names with mixed cases" do
			before do
				user_with_same_name = @user.dup
				user_with_same_name.email.prepend "foo"  # so emails will not be the same
				user_with_same_name.name.upcase!
				user_with_same_name.save
			end

			it { should be_valid }
		end
	end

	describe "when email address is already taken" do
		context "emails have the exact same cases" do
			before do
				user_with_same_email = @user.dup
				user_with_same_email.name.reverse!  # so user names are not the same
				user_with_same_email.save
			end

			it { should_not be_valid }
		end

		context "email addresses with mixed cases" do
			before do
				user_with_same_email = @user.dup
				user_with_same_email.name.reverse!  # so user names are not the same
				user_with_same_email.email.upcase!
				user_with_same_email.save
			end

			it { should_not be_valid }
		end
	end

	describe "when password is not present" do
		before { @user.password = @user.password_confirmation = "" }
		it { should_not be_valid }
	end

	describe "when password confirmation is not present" do
		before { @user.password = "" }
		it { should_not be_valid }
	end

	describe "when password and password confirmation do not match" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end

	describe "when password is too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should_not be_valid }
	end

	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }

		context "with valid password" do
			before do
				@user_with_invalid_email = found_user.authenticate(@user.password)
			end

			it { should == @user_with_invalid_email }
		end

		context "with invalid password" do
			before do
				@user_with_invalid_email = found_user.authenticate("wrong password")
			end

			it { should_not == @user_with_invalid_email }
			specify { @user_with_invalid_email.should be_false }
		end
	end

end
