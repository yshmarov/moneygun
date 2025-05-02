require "ruby_llm"

RubyLLM.configure do |config|
  # Required: At least one API key
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
  config.anthropic_api_key = ENV.fetch("ANTHROPIC_API_KEY", nil)
  config.gemini_api_key = ENV.fetch("GEMINI_API_KEY", nil)
  config.deepseek_api_key = ENV.fetch("DEEPSEEK_API_KEY", nil)

  # Bedrock
  config.bedrock_api_key = ENV.fetch("AWS_ACCESS_KEY_ID", nil)
  config.bedrock_secret_key = ENV.fetch("AWS_SECRET_ACCESS_KEY", nil)
  config.bedrock_region = ENV.fetch("AWS_REGION", nil)
  config.bedrock_session_token = ENV.fetch("AWS_SESSION_TOKEN", nil)

  # Optional: Set default models
  config.default_model = "gpt-4o-mini"               # Default chat model
  config.default_embedding_model = "text-embedding-3-small"  # Default embedding model
  config.default_image_model = "dall-e-3"            # Default image generation model

  # Optional: Configure request settings
  config.request_timeout = 120  # Request timeout in seconds
  config.max_retries = 3        # Number of retries on failures
end
