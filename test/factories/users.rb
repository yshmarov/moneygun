# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}_#{SecureRandom.hex(4)}@example.com" }
    email_verified_at { Time.current }

    trait :unconfirmed do
      email_verified_at { nil }
    end
  end
end
