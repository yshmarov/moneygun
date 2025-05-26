# B2B-only routes
constraints(lambda { |request| Rails.application.config_for(:settings).dig(:app_features, :b2b) == true }) do
  namespace :public do
    resources :organizations, only: %i[index show]
  end
end

resources :organizations, path: I18n.t("routes.organizations") do
  scope module: :organizations do
    resource :transfer, only: %i[show update]
    resources :memberships, except: %i[new create], path: I18n.t("routes.memberships")

    # B2B-only routes within organizations
    constraints(lambda { |request| Rails.application.config_for(:settings).dig(:app_features, :b2b) == true }) do
      resources :invitations, except: %i[edit update]
      resources :membership_requests, only: %i[index] do
        member do
          post :approve
          post :reject
        end
      end
    end

    get "subscriptions", to: "subscriptions#index"
    get "subscriptions/checkout", to: "subscriptions#checkout"
    post "subscriptions/billing_portal", to: "subscriptions#billing_portal"
  end
end
