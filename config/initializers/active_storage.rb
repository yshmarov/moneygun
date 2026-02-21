# frozen_string_literal: true

require_relative "../../lib/rails_ext/active_storage_direct_upload_expiry"

Rails.application.config.active_storage.variant_processor = :vips

Rails.application.config.active_storage.web_image_content_types = %w[
  image/png
  image/jpeg
  image/gif
  image/webp
  image/avif
]

Rails.application.config.active_storage.variable_content_types = %w[
  image/png
  image/jpeg
  image/gif
  image/webp
  image/avif
]
