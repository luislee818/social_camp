require File.expand_path('../../app/models/action_type', __FILE__)

FactoryGirl.define do
  # users
  factory :user do
    sequence(:name) { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@nltechdev.com" }
    password "1234Abcd"
    password_confirmation "1234Abcd"
  end
  
  factory :john, class: :user do
    name 'john'
    email 'john@nltechdev.com'
    password '1234Abcd'
    password_confirmation '1234Abcd'
    admin false
  end
  
  factory :jane, class: :user do
    name 'jane'
    email 'jane@nltechdev.com'
    password '1234Abcd'
    password_confirmation '1234Abcd'
    admin false
  end
  
  factory :admin, class: :user do
    name 'amin'
    email 'admin@nltechdev.com'
    password '1234Abcd'
    password_confirmation '1234Abcd'
    admin true
  end
  
  # discussions
  factory :discussion do
    sequence(:subject) { |n| "Subject #{n}" }
    sequence(:content) { |n| "Content #{n}" }
    user
  end
  
  # comments
  factory :comment do
    sequence(:content) { |n| "Comment #{n}" }
    discussion
    user
  end
  
  # events
  factory :event do
    sequence(:name) { |n| "Event #{n}" }
    sequence(:location) { |n| "Location #{n}" } 
    sequence(:description) { |n| "Description of event #{n}" }
    start_at { rand(10).days.ago }
    user
  end
  
  # changelogs
  factory :changelog do
    user
  end
  
  factory :changelog_add, parent: :changelog do
    action_type_id ActionType::ADD
  end
  
  factory :changelog_update, parent: :changelog do
    action_type_id ActionType::UPDATE
  end
  
  factory :changelog_destroy, parent: :changelog do
    action_type_id ActionType::DESTROY
  end

end
