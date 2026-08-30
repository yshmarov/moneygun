# frozen_string_literal: true

class Sessions::TwoFactorController < ApplicationController
  require_unauthenticated_access
  rate_limit to: 10, within: 10.minutes, only: :create, by: -> { user_pending_two_factor&.id },
             with: -> { redirect_to new_session_two_factor_path, alert: t("sessions.two_factor.rate_limited") }
  before_action :ensure_pending_two_factor

  layout "centered"

  def new; end

  def create
    if @user.verify_otp(params.dig(:two_factor, :code))
      established = establish_authenticated_session(@user, authentication: authentication_pending_two_factor)
      clear_pending_two_factor_token
      established ? redirect_after_sign_in : redirect_to(new_sso_path, alert: t("sessions.sso.denied"))
    else
      AuditLog.log_for_memberships!(@user.memberships, action: "user.two_factor_failed", actor_kind: "system")
      redirect_to new_session_two_factor_path, alert: t("sessions.two_factor.invalid_code")
    end
  end

  private

  def ensure_pending_two_factor
    @user = user_pending_two_factor
    redirect_to new_session_path unless @user
  end
end
