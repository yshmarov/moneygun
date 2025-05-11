resource :discover, only: %i[show]

resources :organizations, path: I18n.t("routes.organizations") do
  scope module: :organizations do
    resources :memberships, except: %i[show], path: I18n.t("routes.memberships")
    resource :transfer, only: %i[show update]
    resources :invitations, only: %i[index destroy]

    get "subscriptions", to: "subscriptions#index"
    get "subscriptions/checkout", to: "subscriptions#checkout"
    post "subscriptions/billing_portal", to: "subscriptions#billing_portal"
  end
end
