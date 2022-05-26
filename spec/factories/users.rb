FactoryBot.define do
  factory :user do
    name { 'Michael Example' }
    email { 'michael@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
  end

  factory :continuous_users, class: User do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end

  factory :other_user, class: User do
    name { 'rails1user' }
    email { 'rails100@user.com' }
    password { 'password2' }
    password_confirmation { 'password2' }
  end
end
