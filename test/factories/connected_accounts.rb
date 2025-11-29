# frozen_string_literal: true

FactoryBot.define do
  factory :connected_account do
    owner { create(:user) }
    provider { "tiktok" }
    sequence(:uid) { |n| "uid-#{n}_#{SecureRandom.hex(4)}" }
    access_token { "1234567890" }
    refresh_token { "1234567890" }
    expires_at { 1.hour.from_now }
    payload { {} }
  end
end
