FactoryBot.define do
  factory :orange, class: Micropost do
    content { 'I just ate an orange!' }
    created_at { 10.minutes.ago }
  end

  factory :posts_user, class: Micropost do
    content { 'Writing a short test2' }
    created_at { Time.zone.now }
    user { association :other_user, email: 'posts@example.com' }
  end

  factory :most_recent, class: Micropost do
    content { 'Writing a short test' }
    created_at { Time.zone.now }
    user { association :user, email: 'recent@example.com' }
  end
end

def user_with_posts(posts_count: 5)
  FactoryBot.create(:user) do |user|
    FactoryBot.create_list(:orange, posts_count, user: user)
  end
end
