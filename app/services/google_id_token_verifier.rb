# frozen_string_literal: true

class GoogleIdTokenVerifier
  CERTS_URL = "https://www.googleapis.com/oauth2/v3/certs"
  ISSUERS   = %w[accounts.google.com https://accounts.google.com].freeze

  # Verifies a Google ID token (JWT) and returns the decoded payload.
  # Raises JWT::DecodeError if the token is invalid.
  def self.verify(token)
    jwks      = fetch_jwks
    client_id = Rails.application.credentials.dig(:google_oauth2, :client_id)

    payload, = JWT.decode(token, nil, true,
                          algorithms: ["RS256"],
                          jwks: jwks,
                          iss: ISSUERS,
                          verify_iss: true,
                          aud: client_id,
                          verify_aud: true)

    payload
  end

  def self.fetch_jwks
    Rails.cache.fetch("google_jwks", expires_in: 1.hour) do
      uri  = URI(CERTS_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl       = true
      http.open_timeout  = 5
      http.read_timeout  = 5
      # OpenSSL 3.x on macOS enforces CRL checks which fail against Google's endpoints.
      # Setting flags to 0 disables CRL verification while keeping certificate validation.
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      store.flags = 0
      http.cert_store = store
      response = http.get(uri.path)
      JSON.parse(response.body)
    end
  end

  private_class_method :fetch_jwks
end
