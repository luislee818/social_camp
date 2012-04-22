namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Dapeng",
                 email: "dpli@nltechdev.com",
                 password: "111111",
                 password_confirmation: "111111")
    admin.toggle!(:admin)
                 
    User.create!(name: "John",
                 email: "john@nltechdev.com",
                 password: "1234Abcd",
                 password_confirmation: "1234Abcd")
           
    User.create!(name: "Jane",
                 email: "jane@nltechdev.com",
                 password: "1234Abcd",
                 password_confirmation: "1234Abcd")
                 
    99.times do |n|
      name  = Faker::Name.name[0...20]
      email = "example-#{n+1}@nltechdev.com"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end