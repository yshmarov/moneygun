# frozen_string_literal: true

module SamlFlowCookie
  NAME = "saml_flow"
  TTL = 10.minutes

  def self.write(request, connection_id:, request_id: nil)
    cross_site = Rails.env.production? || request.host == "localhost"
    request.cookie_jar.encrypted[NAME] = {
      value: { "connection_id" => connection_id, "request_id" => request_id },
      httponly: true,
      expires: TTL.from_now,
      same_site: cross_site ? :none : :lax,
      secure: cross_site
    }
  end

  def self.read(request) = request.cookie_jar.encrypted[NAME]

  def self.consume(request)
    read(request).tap { request.cookie_jar.delete(NAME) }
  end
end
