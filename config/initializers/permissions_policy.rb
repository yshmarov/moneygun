# frozen_string_literal: true

Rails.application.config.permissions_policy do |policy|
  policy.camera :none
  policy.microphone :none
  policy.geolocation :none
  policy.usb :none
  policy.gyroscope :none
  policy.magnetometer :none
  policy.fullscreen :self
  policy.payment :self
end
