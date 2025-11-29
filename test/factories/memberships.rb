# frozen_string_literal: true

FactoryBot.define do
  factory :membership do
    association :organization
    association :user
    role { "member" }

    trait :admin do
      role { "admin" }
    end

    trait :member do
      role { "member" }
    end
  end
end
