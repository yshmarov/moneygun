# frozen_string_literal: true

if defined?(Rack::MiniProfiler)
  Rack::MiniProfiler.config.tap do |config|
    config.auto_inject = false
    config.storage = Rack::MiniProfiler::MemoryStore
    config.skip_paths = %w[/assets /letter_opener /good_job /avo /flipper]
  end
end
