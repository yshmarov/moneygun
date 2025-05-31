class ConnectedAccount < ApplicationRecord
  belongs_to :user

  PROVIDER_CONFIG = {
    google_oauth2: {
      name: "Google",
      icon: "🔍"
    },
    github: {
      name: "GitHub",
      icon: "🐙"
    }
  }.freeze

  def name
    payload&.dig("info", "name")
  end

  def image_url
    payload&.dig("info", "image")
  end
end
