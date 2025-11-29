# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "mission_control-jobs"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails", require: false
  gem "erb_lint", require: false
  gem "dotenv-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "nested_scaffold", github: "yshmarov/nested_scaffold", branch: "master"
  gem "i18n-tasks"
  gem "lookbook", ">= 2.3.9"
  gem "letter_opener"
  gem "letter_opener_web"
  gem "reactionview", "~> 0.1.6"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

# active record
gem "sqids" # for obfuscating IDs
gem "pagy", "~> 9.3"
gem "ransack", "~> 4.2"
gem "active_storage_validations"

# authentication
gem "devise", github: "heartcombo/devise", branch: "main"
gem "devise_invitable", "~> 2.0"
gem "devise_masquerade"

# oauth
gem "omniauth-google-oauth2"
gem "omniauth-github"

# authorization
gem "pundit", "~> 2.3"

# frontend
gem "view_component"
gem "inline_svg", "~> 1.9"
gem "active_link_to", "~> 1.0"
gem "turbo_power", "~> 0.7.0"
gem "rails-i18n"
gem "redcarpet", "~> 3.6"
gem "local_time"
gem "simple_form", "~> 5.4"

# admin
gem "allgood", "~> 0.3.0"
gem "active_storage_dashboard"
gem "avo", ">= 3.22.0"
group :avo, optional: true do
  source "https://packager.dev/avo-hq/" do
    gem "avo-pro"
  end
end
gem "active_analytics"
# feature flags
gem "flipper-active_record"
gem "flipper-ui"

# payments
gem "pay", "~> 8.0"
gem "stripe", "~> 13.0"
gem "profitable"

# business logic
gem "refer"
gem "noticed"

gem "ruby_llm", github: "crmne/ruby_llm", branch: "main"

group :production do
  gem "aws-sdk-s3", "~> 1.205", require: false
end

gem "browser", "~> 6.2"
