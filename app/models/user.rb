# frozen_string_literal: true

class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy

  MAX_AVATAR_SIZE = 3.megabytes.freeze

  has_referrals
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification", dependent: :destroy

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_fit: [256, 256], saver: { strip: true, quality: 80 }, format: :webp
  end

  after_save_commit if: -> { avatar.attached? && attachment_changes["avatar"] } do
    ActiveStorage::PreprocessVariantsJob.perform_later(self, "avatar")
  end

  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :avatar, content_type: IMAGE_CONTENT_TYPES
  validates :avatar, size: { less_than: MAX_AVATAR_SIZE, message: "must be less than #{MAX_AVATAR_SIZE / 1.megabyte}MB" }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def unseen_notifications_count
    @unseen_notifications_count ||= notifications.unseen.count
  end

  def name
    self[:name].presence || identities.first&.name || email.split("@").first
  end

  def avatar_thumbnail
    avatar.variable? ? avatar.variant(:thumb) : avatar
  end
end
