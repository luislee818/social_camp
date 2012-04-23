namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    # users
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

    # events
    25.times do |n|
      event_name = Faker::Lorem.words(rand(6))
      event_location = Faker::Address.street_name
      event_description = Faker::Lorem.paragraph(rand(4))
      event_start_at = rand(10000).minutes.from_now
      event_user_id = rand(100)

      event = Event.new(name: event_name,
                    location: event_location,
                    description: event_description,
                    start_at: event_start_at)
      event.user_id = event_user_id
      event.save
    end

    25.times do |n|
      event_name = Faker::Lorem.words(rand(6))
      event_location = Faker::Address.street_name
      event_description = Faker::Lorem.paragraph(rand(4))
      event_start_at = rand(10000).minutes.ago
      event_user_id = rand(100)

      event = Event.new(name: event_name,
                    location: event_location,
                    description: event_description,
                    start_at: event_start_at)
      event.user_id = event_user_id
      event.save
    end
  end
end