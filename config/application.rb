require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Moneygun
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    config.generators.template_engine = :erb

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.mission_control.jobs.http_basic_auth_enabled = false
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en fr]
    config.i18n.fallbacks = true
    config.view_component.default_preview_layout = "minimal"

    config.to_prepare do
      Noticed::Event.include Noticed::EventExtensions
      Noticed::Notification.include Noticed::NotificationExtensions
    end
  end
end
