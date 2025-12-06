# frozen_string_literal: true

module Organization::Community
  extend ActiveSupport::Concern

  included do
    enum :privacy_setting, %w[private restricted public].index_by(&:itself), default: :private, prefix: true

    validate :public_privacy_setting_requirements

    scope :discoverable, -> { not_privacy_setting_private.has_logo }
  end

  private

  def public_privacy_setting_requirements
    return if privacy_setting_private? || logo.attached?

    errors.add(:privacy_setting, "requires logo to be discoverable for restricted and public organizations")
  end
end
