FactoryBot.define do
  factory :user do
    name { 'Michael Example' }
    email { 'michael@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
    activated { true }
  end

  factory :continuous_users, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    activated { true }
  end

  factory :other_user, class: User do
    name { 'rails1user' }
    email { 'rails100@user.com' }
    password { 'password2' }
    password_confirmation { 'password2' }
    admin { false }
    activated { true }
  end
end
