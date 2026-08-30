# frozen_string_literal: true

require Rails.root.join("lib/required_production_configuration")

RequiredProductionConfiguration.verify! if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
