# frozen_string_literal: true

class Project < ApplicationRecord
  include ScansForViruses
  include StripsFileMetadata

  belongs_to :organization
  belongs_to :membership

  validates :membership, same_organization: true
  validates :name, presence: true, uniqueness: { scope: :organization_id }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name status category priority is_active]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[organization]
  end

  has_rich_text :body

  has_one_attached :document
  has_many_attached :attachments
  has_one_attached :cover_image
  has_many_attached :gallery

  scans_attachments_for_viruses :document, :attachments, :cover_image, :gallery

  validates :cover_image, content_type: IMAGE_CONTENT_TYPES, size: { less_than: 5.megabytes }
  validates :gallery, content_type: IMAGE_CONTENT_TYPES, size: { less_than: 5.megabytes }
  validates :document, size: { less_than: 10.megabytes }
  validates :attachments, size: { less_than: 10.megabytes }

  def active_storage_accessible_to?(user)
    organization.memberships.active.exists?(user: user)
  end
end
