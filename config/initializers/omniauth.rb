# config/initializers/omniauth.rb
require "omniauth"
# require "omniauth-google-oauth2"

# Determine which providers are available
providers = []

# Developer provider (only in non-production)
providers << :developer unless Rails.env.production?

# Google OAuth2
if Rails.application.credentials.dig(:google_oauth2, :client_id).present? &&
   Rails.application.credentials.dig(:google_oauth2, :client_secret).present?
  providers << :google_oauth2
end

# GitHub
if Rails.application.credentials.dig(:github, :key).present? &&
   Rails.application.credentials.dig(:github, :secret).present?
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
               Rails.application.credentials.dig(:google_oauth2, :client_id),
               Rails.application.credentials.dig(:google_oauth2, :client_secret),
               scope: "email,profile"
    when :github
      provider :github,
               Rails.application.credentials.dig(:github, :key),
               Rails.application.credentials.dig(:github, :secret),
               scope: "user:email"
    end
  end
end
