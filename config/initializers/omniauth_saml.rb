# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger
OmniAuth.config.path_prefix = "/auth"

class SamlRequestTracking < OmniAuth::Strategies::SAML
  def request_phase
    request = ActionDispatch::Request.new(env)
    flow = SamlFlowCookie.read(request)
    connection_id = flow&.dig("connection_id")
    return fail!(:invalid_ticket, ValidationError.new("No SSO connection in progress")) if connection_id.blank?

    SamlAuthRequest.consume(flow["request_id"], sso_connection_id: connection_id)
    authn_request = OneLogin::RubySaml::Authrequest.new
    SamlAuthRequest.start(authn_request.uuid, sso_connection_id: connection_id)
    SamlFlowCookie.write(request, connection_id: connection_id, request_id: authn_request.uuid)

    with_settings { |settings| redirect(authn_request.create(settings, additional_params_for_authn_request)) }
  end

  def callback_phase
    flow = SamlFlowCookie.read(ActionDispatch::Request.new(env))
    request_id = flow&.dig("request_id")
    return fail!(:invalid_ticket, ValidationError.new("SAML response has no matching AuthnRequest")) unless SamlAuthRequest.consume(request_id, sso_connection_id: flow&.dig("connection_id"))

    options[:matches_request_id] = request_id
    super
  end
end

SAML_SETUP = lambda do |env|
  request = ActionDispatch::Request.new(env)
  strategy = env["omniauth.strategy"]
  strategy.options[:sp_entity_id] = "#{request.base_url}/auth/saml/metadata"
  strategy.options[:assertion_consumer_service_url] = "#{request.base_url}/auth/saml/callback"

  connection = SsoConnection.enabled.find_by(id: SamlFlowCookie.read(request)&.dig("connection_id"))
  connection&.saml_options(base_url: request.base_url)&.each { |key, value| strategy.options[key] = value }
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider SamlRequestTracking,
           name: :saml,
           setup: SAML_SETUP,
           slo_enabled: false,
           idp_sso_service_url: "https://sso.invalid/placeholder",
           idp_cert: "",
           name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
end
