class BaseClient
  include ActiveSupport::Rescuable

  attr_reader :connection

  def initialize(base_url:, headers: {})
    @connection = Faraday.new(url: base_url) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
      conn.headers.merge!(headers)
    end
  end

  private

  def post(endpoint, payload = {})
    handle_response do
      connection.post(endpoint, payload)
    end
  end

  def get(endpoint, params = {})
    handle_response do
      connection.get(endpoint, params)
    end
  end

  def handle_response
    response = yield
    log_response(response)

    case response.status
    when 200..299
      response.body
    when 400..499
      handle_client_error(response)
    when 500..599
      handle_server_error(response)
    else
      handle_unknown_error(response)
    end
  rescue Faraday::ConnectionFailed => e
    Rails.logger.error "#{self.class.name} connection failed: #{e.message}"
    raise ApiConnectionError, "Failed to connect to #{self.class.name.demodulize}"
  rescue Faraday::TimeoutError => e
    Rails.logger.error "#{self.class.name} timeout: #{e.message}"
    raise ApiTimeoutError, "Request to #{self.class.name.demodulize} timed out"
  end

  def handle_client_error(response)
    Rails.logger.warn "#{self.class.name} client error (#{response.status}): #{response.body}"
    raise ApiClientError.new("Client error: #{response.status}", response.status, response.body)
  end

  def handle_server_error(response)
    Rails.logger.error "#{self.class.name} server error (#{response.status}): #{response.body}"
    raise ApiServerError.new("Server error: #{response.status}", response.status, response.body)
  end

  def handle_unknown_error(response)
    Rails.logger.error "#{self.class.name} unknown error (#{response.status}): #{response.body}"
    raise ApiError.new("Unknown error: #{response.status}", response.status, response.body)
  end

  def log_response(response)
    Rails.logger.info "#{self.class.name} response: #{response.status} - #{response.body&.truncate(200)}"
  end
end

# Custom exception classes
class ApiError < StandardError
  attr_reader :status, :response_body

  def initialize(message, status = nil, response_body = nil)
    super(message)
    @status = status
    @response_body = response_body
  end
end

class ApiConnectionError < ApiError; end
class ApiTimeoutError < ApiError; end
class ApiClientError < ApiError; end
class ApiServerError < ApiError; end
