Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }

  resources :organizations do
    get "dashboard", to: "organizations/dashboard#index"
    get "paywalled_page", to: "organizations/dashboard#paywalled_page"
    scope module: :organizations do
      resources :memberships, except: %i[show]
      resource :transfer, only: %i[show update]
      resources :inboxes
      get "subscriptions", to: "subscriptions#index"
      get "subscriptions/checkout", to: "subscriptions#checkout"
      post "subscriptions/billing_portal", to: "subscriptions#billing_portal"
    end
  end

  get "pricing", to: "static#pricing"
  get "terms", to: "static#terms"
  get "privacy", to: "static#privacy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker", to: "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest", to: "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "static#index"

  authenticate :user, ->(user) { user.admin? } do
    mount Profitable::Engine => "/profitable"
  end
end
