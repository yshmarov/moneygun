class ConnectedAccount < ApplicationRecord
  belongs_to :user

  PROVIDER_CONFIG = {
    google_oauth2: { name: "Google", icon: "🔍" },
    github: { name: "GitHub", icon: "🐙" },
    facebook: { name: "Facebook", icon: "📘" },
    twitter: { name: "Twitter", icon: "🐦" }
  }.freeze
end
