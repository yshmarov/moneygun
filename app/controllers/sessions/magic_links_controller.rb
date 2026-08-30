# frozen_string_literal: true

class Sessions::MagicLinksController < ApplicationController
  require_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :create, name: "ip",
             with: -> { redirect_to session_magic_link_path, alert: t("sessions.magic_links.rate_limited") }
  rate_limit to: 10, within: 15.minutes, only: :create, name: "account",
             by: -> { email_address_pending_authentication.presence || request.remote_ip },
             with: -> { redirect_to session_magic_link_path, alert: t("sessions.magic_links.rate_limited") }
  before_action :ensure_pending_authentication

  layout "centered"

  def show; end

  def create
    magic_link = MagicLink.for_email(email_address_pending_authentication).consume(params.expect(:code), purpose: %i[sign_in sign_up])

    if magic_link&.user&.can_authenticate_with_magic_link?
      clear_pending_authentication_token
      magic_link.user.verify_email!
      sign_in_or_verify_two_factor magic_link.user, authentication: { "method" => "magic_link" }
    else
      redirect_to session_magic_link_path, alert: t("sessions.magic_links.invalid_code")
    end
  end

  private

  def ensure_pending_authentication
    return if email_address_pending_authentication.present?

    redirect_to new_session_path, alert: t("sessions.magic_links.enter_email_first")
  end
end
