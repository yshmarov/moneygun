# frozen_string_literal: true

module DeviceFormat
  extend ActiveSupport::Concern

  included do
    before_action :set_variant
  end

  private

  def set_variant
    # request.variant = :mobile if turbo_native_app? || browser.device.mobile?
    # request.variant = :mobile if browser.device.mobile?
    request.variant = :native if turbo_native_app?
  end
end
