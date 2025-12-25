# frozen_string_literal: true

namespace :hotwire_native do
  namespace :android do
    resource :path_configuration, only: :show
  end
  namespace :ios do
    resource :path_configuration, only: :show
  end

  # Mobile sign out endpoint
  resource :auth, only: [:destroy], defaults: { format: :json }

  # Notification token management for push notifications
  resources :notification_tokens, param: :token, only: %i[create destroy], defaults: { format: :json }
end
