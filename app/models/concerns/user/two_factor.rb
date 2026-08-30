# frozen_string_literal: true

module User::TwoFactor
  extend ActiveSupport::Concern

  OTP_ISSUER = "Moneygun"
  BACKUP_CODE_COUNT = 10
  DRIFT_SECONDS = 15

  included do
    encrypts :otp_secret
    encrypts :otp_backup_codes
  end

  def two_factor_enabled?
    otp_enabled_at?
  end

  def otp_provisioning_uri(secret)
    ROTP::TOTP.new(secret, issuer: OTP_ISSUER).provisioning_uri(email)
  end

  def verify_otp(code)
    return false unless otp_secret? && two_factor_enabled?

    normalized = code.to_s.strip.downcase
    return totp_valid?(normalized) if normalized.match?(/\A\d{6}\z/)
    return consume_backup_code!(normalized) if normalized.match?(/\A[0-9a-f]{8}\z/)

    false
  end

  def enable_two_factor!(secret)
    codes = Array.new(BACKUP_CODE_COUNT) { SecureRandom.hex(4) }
    update!(otp_secret: secret, otp_enabled_at: Time.current, otp_backup_codes: codes.to_json)
    AuditLog.log_for_memberships!(memberships, action: "user.two_factor_enabled")
    codes
  end

  def disable_two_factor!
    update!(otp_secret: nil, otp_backup_codes: nil, otp_enabled_at: nil)
    AuditLog.log_for_memberships!(memberships, action: "user.two_factor_disabled")
  end

  def remaining_backup_codes_count
    backup_codes_list.size
  end

  private

  def totp_valid?(code)
    ROTP::TOTP.new(otp_secret).verify(code, drift_behind: DRIFT_SECONDS, drift_ahead: DRIFT_SECONDS).present?
  end

  def backup_codes_list
    JSON.parse(otp_backup_codes || "[]")
  end

  def consume_backup_code!(code)
    with_lock do
      codes = backup_codes_list
      index = codes.index { |candidate| ActiveSupport::SecurityUtils.secure_compare(candidate, code) }
      next false unless index

      codes.delete_at(index)
      update!(otp_backup_codes: codes.to_json)
      true
    end
  end
end
