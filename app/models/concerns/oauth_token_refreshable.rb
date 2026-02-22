# frozen_string_literal: true

# Shared concern for models that store OAuth2 tokens and need automatic refresh.
#
# Models including this concern must:
# - Have columns: access_token, refresh_token, expires_at, refresh_token_invalidated_at
# - Define REFRESHABLE_PROVIDERS constant (array of provider/platform strings)
# - Implement #oauth_provider_identifier (returns the string used for OAuth config lookup)
# - Implement #oauth_token_owner (returns the user to notify on token invalidation)
module OauthTokenRefreshable
  extend ActiveSupport::Concern

  def token
    if can_refresh? && expired?
      with_lock do
        reload
        renew_token! if can_refresh? && expired?
      end
    end
    access_token
  end

  def expired?
    return false unless expires_at?

    expires_at <= 10.minutes.from_now
  end

  def can_refresh?
    self.class::REFRESHABLE_PROVIDERS.include?(oauth_provider_identifier) &&
      refresh_token.present? &&
      refresh_token_invalidated_at.nil?
  end

  def renew_token!
    new_token = current_token.refresh!
    update(
      access_token: new_token.token,
      refresh_token: new_token.refresh_token || refresh_token,
      expires_at: new_token.expires_at ? Time.zone.at(new_token.expires_at) : nil,
      refresh_token_invalidated_at: nil
    )
  rescue OAuth2::Error => e
    if e.code == "invalid_grant" || e.description&.include?("expired") || e.description&.include?("revoked")
      update(refresh_token_invalidated_at: Time.current)
      return nil
    end
    raise e
  end

  private

  def current_token
    OAuth2::AccessToken.new(
      oauth2_client,
      access_token,
      refresh_token: refresh_token
    )
  end

  def oauth2_client
    config = provider_oauth_config
    OAuth2::Client.new(
      config[:client_id],
      config[:client_secret],
      site: config[:site],
      authorize_url: config[:authorize_url],
      token_url: config[:token_url]
    )
  end

  def provider_oauth_config
    case oauth_provider_identifier
    when "google_oauth2"
      {
        client_id: Rails.application.credentials.dig(:google_oauth2, :client_id),
        client_secret: Rails.application.credentials.dig(:google_oauth2, :client_secret),
        site: "https://accounts.google.com",
        authorize_url: "/o/oauth2/auth",
        token_url: "/o/oauth2/token"
      }
    else
      raise NotImplementedError, "Token refresh not supported for provider: #{oauth_provider_identifier}"
    end
  end
end
