class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy

  has_referrals
  has_many :notifications, as: :recipient, class_name: 'Noticed::Notification', dependent: :destroy

  def self.ransackable_attributes(_auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def unseen_notifications_count
    notifications.unseen.count
  end
end
