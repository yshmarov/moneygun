Rails.application.routes.draw do
  draw :users
  draw :organizations
  draw :admin

  resources :organizations, path: I18n.t("routes.organizations") do
    scope module: :organizations do
      # put application-specific resources scoped to the organization here
      resources :projects
      get "dashboard", to: "dashboard#index"
      get "paywalled_page", to: "dashboard#paywalled_page"

      resources :credits, only: %i[index create]
      resources :refills, only: %i[index] do
        collection do
          post :add_payment_method
          post :charge_payment_method
          post :billing_portal
          patch :update_auto_refill
          #
          patch :spend_some_credits
          patch :spend_bulk_credits
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "static#index"
  get "pricing", to: "static#pricing"
  get "terms", to: "static#terms"
  get "privacy", to: "static#privacy"
end
