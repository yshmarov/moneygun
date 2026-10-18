# frozen_string_literal: true

Rails.application.config.action_dispatch.default_headers["Permissions-Policy"] =
  "camera=(), microphone=(), geolocation=(), usb=(), gyroscope=(), magnetometer=(), fullscreen=(self), payment=(self)"
