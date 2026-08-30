# frozen_string_literal: true

module Organizations::SsoConnectionsHelper
  def sso_acs_url
    "#{request.base_url}/auth/saml/callback"
  end

  def sso_sp_entity_id
    "#{request.base_url}/auth/saml/metadata"
  end
end
