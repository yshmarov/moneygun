Rails.application.routes.draw do
  draw :users
  draw :organizations
  draw :admin

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up', to: 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'static#index'
  get 'pricing', to: 'static#pricing'
  get 'terms', to: 'static#terms'
  get 'privacy', to: 'static#privacy'
  get 'refunds', to: 'static#refunds'

  get 'search', to: 'search#index'
end
