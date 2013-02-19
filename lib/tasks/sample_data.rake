namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    # users
    admin = User.new(name: "Dapeng",
                 email: "dpli@nltechdev.com",
                 password: "111111",
                 password_confirmation: "111111")
    admin.toggle!(:admin)
    admin.save

    User.create!(name: "John",
                 email: "john@nltechdev.com",
                 password: "1234Abcd",
                 password_confirmation: "1234Abcd")

    User.create!(name: "Jane",
                 email: "jane@nltechdev.com",
                 password: "1234Abcd",
                 password_confirmation: "1234Abcd")

    (4..100).each do |n|
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
      event_name = Faker::Lorem.words(rand(6) + 1)
      event_location = Faker::Address.street_name
      event_description = Faker::Lorem.paragraph(rand(4) + 1)
      event_start_at = rand(10000).minutes.from_now
      event_user_id = rand(100) + 1 # random number from 1 to 100

      event = Event.new(name: event_name,
                    location: event_location,
                    description: event_description,
                    start_at: event_start_at)
      event.user_id = event_user_id
      event.save!

      event.changelogs.create! user_id: event_user_id,
                              action_type_id: ActionType::ADD
    end

    25.times do |n|
      event_name = Faker::Lorem.words(rand(6) + 1)
      event_location = Faker::Address.street_name
      event_description = Faker::Lorem.paragraph(rand(4) + 1)
      event_start_at = rand(10000).minutes.ago
      event_user_id = rand(100) + 1 # random number from 1 to 100

      event = Event.new(name: event_name,
                    location: event_location,
                    description: event_description,
                    start_at: event_start_at)
      event.user_id = event_user_id
      event.save

      event.changelogs.create! user_id: event_user_id,
                              action_type_id: ActionType::ADD
    end

    # discussions
    100.times do |n|
      discussion_subject = Faker::Lorem.words(rand(6) + 1)[0...50]
      discussion_content = Faker::Lorem.paragraph(rand(4) + 1)
      discussion_user_id = rand(100) + 1 # random number from 1 to 100

      discussion = Discussion.new(subject: discussion_subject,
                             content: discussion_content)
      discussion.user_id = discussion_user_id

      discussion.save!

      discussion.changelogs.create! user_id: discussion_user_id,
                              action_type_id: ActionType::ADD
    end

    # comments
    200.times do |n|
      comment_content = Faker::Lorem.paragraph(rand(4) + 1)
      comment_user_id = rand(100) + 1 # random number from 1 to 100

      discussion = Discussion.find (rand(10) + 1)
      comment = discussion.comments.new content: comment_content
      comment.user_id = comment_user_id

      comment.save!

      comment.changelogs.create! user_id: comment_user_id,
                              action_type_id: ActionType::ADD
    end
  end
end
