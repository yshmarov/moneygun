# frozen_string_literal: true

# config/initializers/omniauth.rb
require "omniauth"
# require "omniauth-google-oauth2"
OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

# Determine which providers are available
providers = []

# Developer provider (only in development)
providers << :developer if Rails.env.development?

# Google OAuth2
if Rails.app.creds.option(:google_oauth2, :client_id).present? &&
   Rails.app.creds.option(:google_oauth2, :client_secret).present?
  providers << :google_oauth2
end

# GitHub
if Rails.app.creds.option(:github, :key).present? &&
   Rails.app.creds.option(:github, :secret).present?
  providers << :github
end

# Store providers in Rails config for access from helpers
Rails.application.config.omniauth_providers = providers

# Configure OmniAuth middleware
Rails.application.config.middleware.use OmniAuth::Builder do
  providers.each do |provider_name|
    case provider_name
    when :developer
      provider :developer
    when :google_oauth2
      provider :google_oauth2,
               Rails.app.creds.option(:google_oauth2, :client_id),
               Rails.app.creds.option(:google_oauth2, :client_secret),
               scope: "email,profile"
    when :github
      provider :github,
               Rails.app.creds.option(:github, :key),
               Rails.app.creds.option(:github, :secret),
               scope: "user:email"
    end
  end
end
