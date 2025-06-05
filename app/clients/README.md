# API Clients

This directory contains all external API clients for the application. Each client follows a consistent pattern for maintainability and reliability.

## Structure

```
app/clients/
├── base_client.rb          # Shared functionality for all clients
├── telegram_client.rb      # Telegram Bot API client
├── stripe_client.rb        # Stripe API client (example)
└── README.md              # This file
```

## Base Client

All API clients inherit from `BaseClient`, which provides:

- Consistent HTTP connection setup via Faraday
- Automatic JSON request/response handling
- Comprehensive error handling with custom exceptions
- Request/response logging
- Standardized error classes:
  - `ApiError` - Base error class
  - `ApiConnectionError` - Network connection failures
  - `ApiTimeoutError` - Request timeouts
  - `ApiClientError` - 4xx HTTP responses
  - `ApiServerError` - 5xx HTTP responses

## Creating New Clients

When adding a new API client:

1. **Inherit from BaseClient**: `class YourClient < BaseClient`

2. **Set up initialization**: Configure base URL and headers

   ```ruby
   def initialize
     @api_key = Rails.application.credentials.dig(:your_service, :api_key)
     raise ConfigurationError, "API key not found" unless @api_key

     super(
       base_url: "https://api.yourservice.com",
       headers: { 'Authorization' => "Bearer #{@api_key}" }
     )
   end
   ```

3. **Define public methods**: Create methods for each API endpoint

   ```ruby
   def create_resource(data)
     post("/v1/resources", data)
   end
   ```

4. **Use credentials**: Store API keys in Rails credentials, not environment variables

5. **Handle configuration errors**: Raise meaningful errors for missing configuration

## Usage Examples

### Direct client usage:

```ruby
client = TelegramClient.new
client.kick_user("123456789")
```

### Via model wrapper (recommended):

```ruby
Telegram.kick_user("123456789")
```

## Error Handling

All clients raise structured exceptions that can be rescued:

```ruby
begin
  TelegramClient.new.kick_user("invalid")
rescue ApiClientError => e
  Rails.logger.warn "Client error: #{e.message} (#{e.status})"
rescue ApiServerError => e
  Rails.logger.error "Server error: #{e.message}"
rescue ApiConnectionError => e
  Rails.logger.error "Connection failed: #{e.message}"
end
```

## Testing

Create corresponding specs in `spec/clients/` following the same naming convention.

Use VCR or WebMock for external API testing to avoid making real API calls during tests.
