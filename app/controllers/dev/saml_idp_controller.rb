# frozen_string_literal: true

# A SAML identity provider to develop against, so the whole round trip can be
# walked in a browser without standing up an Okta or Entra tenant. It speaks the
# real protocol — Saml::MockIdp mints properly signed assertions — so what
# passes here is what an IdP would have to send.
#
# `bin/rails saml:mock_idp` points an organization's connection at it.
#
# Routed only in development and test (see config/routes/sso.rb); the guard here
# is the second lock, so the class can never answer a request in production.
class Dev::SamlIdpController < ApplicationController
  ENTITY_ID = "urn:moneygun:mock-idp"

  allow_unauthenticated_access
  # The service provider posts the AuthnRequest cross-form; a real IdP has no
  # session with us to protect.
  skip_forgery_protection
  before_action :ensure_development

  layout "centered"

  def metadata
    render xml: idp.metadata.to_s
  end

  # The AuthnRequest lands here. A real IdP would authenticate the person; we
  # ask which identity to assert.
  def new
    @authn_request = Saml::MockIdp.parse_authn_request(params[:SAMLRequest])
    @emails = User.order(:email).limit(25).pluck(:email)
  end

  # Signs the assertion and hands it back for the browser to POST to the ACS.
  def create
    @acs_url = params[:acs_url]
    @saml_response = idp.sign_in(
      email: params[:email].to_s.strip,
      name: params[:name].presence,
      acs_url: @acs_url,
      sp_entity_id: params[:sp_entity_id],
      in_response_to: params[:in_response_to]
    )
  end

  private

  def idp
    @idp ||= Saml::MockIdp.new(entity_id: ENTITY_ID, sso_url: dev_saml_sso_url)
  end

  def ensure_development
    raise ActionController::RoutingError, "Not Found" unless Rails.env.local?
  end
end
