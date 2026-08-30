# frozen_string_literal: true

module Organization::Logo
  extend ActiveSupport::Concern

  MAX_LOGO_SIZE = 3.megabytes.freeze

  included do
    has_one_attached :logo do |attachable|
      attachable.variant :thumb, resize_to_fit: [256, 256], saver: { strip: true, quality: 80 }, format: :webp
    end

    after_save { @preprocess_logo = attachment_changes["logo"].present? }
    after_commit :preprocess_logo, on: %i[create update]

    validates :logo, content_type: ApplicationRecord::IMAGE_CONTENT_TYPES
    validates :logo, size: { less_than: MAX_LOGO_SIZE, message: "must be less than #{MAX_LOGO_SIZE / 1.megabyte}MB" }

    scope :has_logo, -> { left_joins(:logo_attachment).where.not(active_storage_attachments: { id: nil }) }
    scope :with_logo, -> { preload(:logo_attachment) }
  end

  def logo_thumbnail
    logo.variable? ? logo.variant(:thumb) : logo
  end

  private

  def preprocess_logo
    ActiveStorage::PreprocessVariantsJob.perform_later(self, "logo") if @preprocess_logo && logo.attached?
  ensure
    @preprocess_logo = false
  end
end
