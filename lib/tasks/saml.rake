# frozen_string_literal: true

namespace :saml do
  desc "Point an organization's SSO connection at the local mock IdP (ORG=id DOMAIN=acme.test)"
  task mock_idp: :environment do
    abort "Development only." unless Rails.env.development?

    organization = ENV["ORG"] ? Organization.find(ENV["ORG"]) : Organization.first
    abort "No organization to configure." unless organization

    domains = ENV.fetch("DOMAIN", nil).presence&.split(",") || organization.users.pluck(:email).filter_map { |email| SsoConnection.domain_for(email) }.uniq
    abort "No email domain to route. Pass DOMAIN=acme.test." if domains.empty?

    idp = Saml::MockIdp.new(entity_id: Dev::SamlIdpController::ENTITY_ID, sso_url: Rails.application.routes.url_helpers.dev_saml_sso_url)
    connection = organization.sso_connection || organization.build_sso_connection
    connection.assign_attributes(
      idp_entity_id: idp.entity_id,
      idp_sso_url: idp.sso_url,
      idp_cert: idp.certificate_pem,
      jit_provisioning: true
    )
    # Save disabled first: enabling requires a verified domain to already exist.
    connection.update!(enabled: false)
    # A made-up development domain has no DNS to prove, so mark it verified here
    # rather than sending anyone to publish a TXT record for acme.test.
    domains.each do |domain|
      connection.sso_domains.find_or_create_by!(domain: domain).update!(verified_at: Time.current)
    end
    connection.update!(enabled: true)

    puts <<~MESSAGE
      Mock IdP wired up for #{organization.name}.

        Domains routed here: #{domains.join(', ')}
        IdP sign-on URL:     #{idp.sso_url}
        IdP metadata:        #{Rails.application.routes.url_helpers.dev_saml_metadata_url}

      Sign in at /sso with an address in one of those domains.
    MESSAGE
  end
end
