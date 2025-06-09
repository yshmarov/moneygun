class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include ObfuscatesId

  IMAGE_CONTENT_TYPES = [ "image/webp", "image/png", "image/jpeg", "image/gif" ].freeze
  VIDEO_CONTENT_TYPES = [ "video/mp4", "video/quicktime", "video/x-msvideo" ].freeze
end
