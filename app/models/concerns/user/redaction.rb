# frozen_string_literal: true

module User::Redaction
  extend ActiveSupport::Concern

  REDACTED_EMAIL_DOMAIN = "users.moneygun.invalid"

  included do
    scope :redacted, -> { where.not(redacted_at: nil) }
  end

  def redacted?
    redacted_at.present?
  end

  def erase!
    return false if undeletable_reasons.any?

    retained_footprint? ? redact! : destroy
  end

  private

  def redact!
    return false if redacted? || undeletable_reasons.any?

    transaction do
      purge_received_invitations
      memberships.active.find_each { |membership| membership.update!(deactivated_at: Time.current) }
      sessions.delete_all
      magic_links.delete_all
      notifications.destroy_all
      disable_two_factor! if two_factor_enabled?
      update!(
        email: "redacted-#{id}@#{REDACTED_EMAIL_DOMAIN}",
        locale: nil,
        metadata: {},
        marketing_consent: false,
        redacted_at: Time.current
      )
    end

    true
  end
end
