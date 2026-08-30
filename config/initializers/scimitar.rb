# frozen_string_literal: true

Rails.application.config.to_prepare do
  Scimitar.service_provider_configuration = Scimitar::ServiceProviderConfiguration.new(
    bulk: Scimitar::Supportable.unsupported
  )

  Scimitar.engine_configuration = Scimitar::EngineConfiguration.new(
    application_controller_mixin: Module.new do
      def self.included(base)
        base.class_eval { skip_forgery_protection }
      end
    end,
    token_authenticator: lambda do |token, _options|
      connection = ScimConnection.authenticate(token)
      next false unless connection&.enabled?

      connection.update_column(:last_request_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
      Current.organization = connection.organization
      Current.scim_connection = connection
      Current.actor_kind = "scim"
      true
    end
  )
end
