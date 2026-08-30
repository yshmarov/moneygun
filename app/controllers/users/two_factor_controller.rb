# frozen_string_literal: true

class Users::TwoFactorController < ApplicationController
  rate_limit to: 10, within: 10.minutes, only: %i[create destroy], by: -> { current_user&.id },
             with: -> { redirect_to user_path, alert: t("users.two_factor.rate_limited") }
  before_action :redirect_if_two_factor_enabled, only: :new
  before_action -> { require_sudo(:enable_two_factor) }, only: %i[new create]

  def show
    @backup_codes = session.delete(:two_factor_backup_codes)
    redirect_to user_path unless @backup_codes
  end

  def new
    @otp_secret = session[:otp_setup_secret] ||= ROTP::Base32.random
    @qr_code = RQRCode::QRCode.new(current_user.otp_provisioning_uri(@otp_secret))
  end

  def edit
    redirect_to user_path unless current_user.two_factor_enabled?
  end

  def create
    secret = session[:otp_setup_secret]
    return redirect_to user_path unless secret

    totp = ROTP::TOTP.new(secret)
    if totp.verify(params.dig(:two_factor, :code).to_s, drift_behind: User::TwoFactor::DRIFT_SECONDS, drift_ahead: User::TwoFactor::DRIFT_SECONDS)
      session.delete(:otp_setup_secret)
      session[:two_factor_backup_codes] = current_user.enable_two_factor!(secret)
      redirect_to user_two_factor_path
    else
      redirect_to new_user_two_factor_path, alert: t("users.two_factor.invalid_code")
    end
  end

  def destroy
    if current_user.two_factor_enabled? && current_user.verify_otp(params.dig(:two_factor, :code))
      current_user.disable_two_factor!
      redirect_to user_path
    else
      AuditLog.log_for_memberships!(current_user.memberships.active, action: "user.two_factor_failed")
      redirect_to user_path, alert: t("users.two_factor.invalid_code")
    end
  end

  private

  def redirect_if_two_factor_enabled
    redirect_to user_path if current_user.two_factor_enabled?
  end
end
