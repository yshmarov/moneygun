namespace :public do
  resources :organizations, only: %i[index show]
end

resources :organizations, path: I18n.t("routes.organizations") do
  scope module: :organizations do
    resource :transfer, only: %i[show update]
    resources :memberships, except: %i[new create], path: I18n.t("routes.memberships")
    resources :invitations, except: %i[edit update]
    resources :membership_requests, only: %i[index] do
      member do
        post :approve
        post :reject
      end
    end

    get "subscriptions", to: "subscriptions#index"
    get "subscriptions/checkout", to: "subscriptions#checkout"
    post "subscriptions/billing_portal", to: "subscriptions#billing_portal"

    # put application-specific resources scoped to the organization below
    resources :projects
    get "dashboard", to: "dashboard#index"
    get "paywalled_page", to: "dashboard#paywalled_page"

    namespace :stripe do
      resource :connect, only: %i[show] do
        collection do
          get :setup
          get :dashboard
          post :restart
        end
      end
    end
  end
end
