# frozen_string_literal: true

class Session < ApplicationRecord
  TOUCH_LAST_SEEN_INTERVAL = 15.minutes
  IDLE_TIMEOUT = 14.days

  belongs_to :user

  scope :expired, -> { where("COALESCE(last_seen_at, created_at) < ?", IDLE_TIMEOUT.ago) }

  def self.cleanup
    expired.delete_all
  end

  def self.resume_from_cookie(cookie_value, cookies: nil)
    return if cookie_value.blank?

    session = find_signed(cookie_value)
    return unless session

    if session.expired?
      session.destroy
      cookies&.delete(:session_token)
      return
    end

    session.touch_last_seen
    session
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def touch_last_seen
    return if last_seen_at && last_seen_at > TOUCH_LAST_SEEN_INTERVAL.ago

    update_column(:last_seen_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def expired?
    (last_seen_at || created_at) < IDLE_TIMEOUT.ago
  end

  def browser
    @browser ||= Browser.new(user_agent.to_s)
  end

  def browser_name
    browser.name.presence unless browser.unknown?
  end

  PLATFORM_NAMES = { ios: "iOS", android: "Android", mac: "macOS", windows: "Windows", linux: "Linux", chrome_os: "ChromeOS" }.freeze

  def platform_name
    PLATFORM_NAMES.find { |key, _| browser.platform.public_send(:"#{key}?") }&.last
  end

  def mobile?
    browser.device.mobile? || browser.device.tablet?
  end
end
