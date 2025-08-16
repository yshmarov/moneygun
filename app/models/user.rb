class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy
  has_referrals
  has_many :notifications, as: :recipient, class_name: "Noticed::Notification"

  def self.ransackable_attributes(auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def unseen_notifications_count
    notifications.unseen.count
  end
end
