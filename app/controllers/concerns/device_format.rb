# frozen_string_literal: true

module DeviceFormat
  extend ActiveSupport::Concern

  included do
    before_action :set_variant
  end

  private

  def set_variant
    if turbo_native_app?
      request.variant = %i[native mobile]
    elsif browser.device.mobile?
      request.variant = %i[mobile]
    end
  end
end
