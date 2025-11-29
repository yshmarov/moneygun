# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    association :owner, factory: :user
    privacy_setting { "private" }

    trait :public do
      privacy_setting { "public" }
      after(:build) do |organization|
        organization.logo.attach(
          io: Rails.root.join("test/fixtures/files/superails-logo.png").open,
          filename: "logo.png"
        )
      end
    end

    trait :restricted do
      privacy_setting { "restricted" }
      after(:build) do |organization|
        organization.logo.attach(
          io: Rails.root.join("test/fixtures/files/superails-logo.png").open,
          filename: "logo.png"
        )
      end
    end

    trait :with_logo do
      after(:create) do |organization|
        organization.logo.attach(
          io: Rails.root.join("test/fixtures/files/superails-logo.png").open,
          filename: "logo.png"
        )
      end
    end
  end
end
