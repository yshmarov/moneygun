# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"] || Rails.application.credentials[:openai_api_key]
  config.gemini_api_key = Rails.application.credentials[:google_gemini_api_key]

  config.default_model = "gpt-4.1-nano"
  # config.default_image_model = "gemini-2.5-flash-image-preview"

  config.use_new_acts_as = true
end
