# frozen_string_literal: true

class Users::SudoController < ApplicationController
  rate_limit to: 20, within: 10.minutes, only: :create, name: "ip",
             with: -> { redirect_to new_sudo_path, alert: t("users.sudo.rate_limited") }
  rate_limit to: 10, within: 10.minutes, only: :create, name: "account", by: -> { current_user&.id },
             with: -> { redirect_to new_sudo_path, alert: t("users.sudo.rate_limited") }
  rate_limit to: 5, within: 15.minutes, only: :resend, name: "resend", by: -> { current_user&.id },
             with: -> { redirect_to new_sudo_path, alert: t("users.sudo.rate_limited") }

  layout "centered"

  def new
    prepare_challenge
    issue_sudo_code unless @two_factor
  end

  def create
    if verify_sudo_challenge
      start_sudo!
      AuditLog.log_for_memberships!(current_user.memberships.active, action: "user.sudo_granted")
      session.delete(:sudo_reason)
      redirect_to session.delete(:sudo_return_to) || default_authenticated_path
    else
      AuditLog.log_for_memberships!(current_user.memberships.active, action: "user.sudo_failed")
      prepare_challenge
      flash.now[:alert] = t("users.sudo.invalid_code")
      render :new, status: :unprocessable_content
    end
  end

  def resend
    if current_user.two_factor_enabled?
      redirect_to new_sudo_path
    else
      serve_development_magic_link current_user.send_magic_link(for: :sudo)
      redirect_to new_sudo_path, notice: t("users.sudo.resent")
    end
  end

  private

  def prepare_challenge
    @two_factor = current_user.two_factor_enabled?
    @reason = session[:sudo_reason]
    @cancel_path = session[:sudo_return_to] || default_authenticated_path
  end

  def verify_sudo_challenge
    if current_user.two_factor_enabled?
      current_user.verify_otp(params[:code])
    else
      current_user.magic_links.consume(params[:code], purpose: :sudo).present?
    end
  end

  def issue_sudo_code
    return if current_user.magic_links.for_sudo.active.exists?

    serve_development_magic_link current_user.send_magic_link(for: :sudo)
  end
end
