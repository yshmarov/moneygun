class Organization < ApplicationRecord
  include Organization::Multitenancy
  include Organization::Transfer
  include Organization::Billing

  enum :privacy_setting, %w[private restricted public].index_by(&:itself), default: :private, prefix: true
  validate :public_privacy_setting_requirements

  has_many :projects, dependent: :destroy

  MIN_NAME_LENGTH = 3
  MAX_NAME_LENGTH = 20

  validates :name, presence: true
  validates :name, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }

  validates :logo, content_type: IMAGE_CONTENT_TYPES
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.discoverable
    not_privacy_setting_private
      .left_joins(:logo_attachment).where.not(active_storage_attachments: { id: nil })
  end

  private

  def public_privacy_setting_requirements
    return if privacy_setting_private? || logo.attached?

    errors.add(:privacy_setting, "requires logo to be discoverable for restricted and public organizations")
  end
end
