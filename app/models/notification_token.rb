# frozen_string_literal: true

class NotificationToken < ApplicationRecord
  # Tokens for sending push notifications to mobile devices

  belongs_to :user
  validates :token, presence: true
  validates :platform, presence: true, inclusion: { in: %w[iOS fcm] }

  scope :android, -> { where(platform: "fcm") }
  scope :ios, -> { where(platform: "iOS") }
end
