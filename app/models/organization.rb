class Organization < ApplicationRecord
  include Organization::Multitenancy
  include Organization::Transfer
  include Organization::Billing

  enum :privacy_setting, { private: "private", restricted: "restricted", public: "public" }, default: :private, prefix: true

  has_many :projects, dependent: :destroy

  MIN_NAME_LENGTH = 3
  MAX_NAME_LENGTH = 20

  validates :name, presence: true
  validates :name, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }

  validates :logo, content_type: IMAGE_CONTENT_TYPES
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
