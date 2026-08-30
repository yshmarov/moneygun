# frozen_string_literal: true

class Sessions::SsoController < ApplicationController
  require_unauthenticated_access only: %i[show new create]
  allow_unauthenticated_access only: %i[callback failure]
  skip_forgery_protection only: :callback
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_sso_path, alert: t("shared.errors.rate_limit") }

  layout "centered"

  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_sso_path(email_address: params[:email_address].to_s.strip.presence), alert: t("shared.errors.session_expired")
  end

  content_security_policy only: :show do |policy|
    policy.form_action :self, -> { @connection&.idp_sso_url }
  end

  def show
    @connection = SsoConnection.enabled.find_by(id: SamlFlowCookie.read(request)&.dig("connection_id"))
    redirect_to new_sso_path unless @connection
  end

  def new
    @email_address = params[:email_address].to_s
  end

  def create
    connection = SsoConnection.discoverable_for_email(params[:email_address])
    if connection
      SamlFlowCookie.write(request, connection_id: connection.id)
      redirect_to sso_path, status: :see_other
    else
      redirect_to new_sso_path(email_address: params[:email_address]), alert: t("sessions.sso.not_available")
    end
  end

  def callback
    flow = SamlFlowCookie.consume(request)
    connection = SsoConnection.enabled.find_by(id: flow&.dig("connection_id"))
    return redirect_to(new_sso_path, alert: t("sessions.sso.failed")) unless connection

    Current.organization = connection.organization
    Current.sso_connection = connection
    Current.actor_kind = "sso"
    membership = connection.sign_in_membership(asserted_email, name: asserted_name)

    if membership
      membership.user.verify_email!
      sign_in_or_verify_two_factor(membership.user, authentication: {
                                     "method" => "sso", "connection_id" => connection.id, "membership_id" => membership.id
                                   })
    else
      redirect_to new_sso_path, alert: t("sessions.sso.denied")
    end
  end

  def failure
    SamlFlowCookie.consume(request)
    redirect_to new_sso_path, alert: t("sessions.sso.failed")
  end

  private

  def auth_hash = request.env["omniauth.auth"] || {}
  def asserted_email = auth_hash.dig(:info, :email).presence || auth_hash[:uid]
  def asserted_name = auth_hash.dig(:info, :name).presence
end
