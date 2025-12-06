# frozen_string_literal: true

module Organization::Logo
  extend ActiveSupport::Concern

  MAX_LOGO_SIZE = 1.megabyte.freeze

  included do
    has_one_attached :logo do |attachable|
      attachable.variant :thumb, resize_to_fill: [256, 256]
    end

    validates :logo, content_type: ApplicationRecord::IMAGE_CONTENT_TYPES
    validates :logo, size: { less_than: MAX_LOGO_SIZE, message: "must be less than #{MAX_LOGO_SIZE}MB" }

    scope :has_logo, -> { left_joins(:logo_attachment).where.not(active_storage_attachments: { id: nil }) }
    scope :with_logo, -> { preload(:logo_attachment) }
  end

  def logo_thumbnail
    logo.variable? ? logo.variant(:thumb) : logo
  end
end
