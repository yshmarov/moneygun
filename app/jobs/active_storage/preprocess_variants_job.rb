# frozen_string_literal: true

module ActiveStorage
  class PreprocessVariantsJob < ApplicationJob
    queue_as :default

    def perform(record, attachment_name)
      attachment = record.public_send(attachment_name)
      return unless attachment.attached? && attachment.variable?

      record.attachment_reflections[attachment_name].named_variants.each_key do |variant_name|
        attachment.variant(variant_name).processed
      end
    end
  end
end
