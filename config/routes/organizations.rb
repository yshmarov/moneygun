namespace :public do
  resources :organizations, only: %i[index show]
end

resources :organizations, path: I18n.t("routes.organizations") do
  scope module: :organizations do
    resources :memberships, except: %i[show], path: I18n.t("routes.memberships")
    resource :transfer, only: %i[show update]
    resources :invitations, only: %i[index destroy]
    resources :membership_requests, only: %i[index] do
      member do
        post :approve
        post :reject
      end
    end

    get "subscriptions", to: "subscriptions#index"
    get "subscriptions/checkout", to: "subscriptions#checkout"
    post "subscriptions/billing_portal", to: "subscriptions#billing_portal"
  end
end
