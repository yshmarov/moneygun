devise_for :users, controllers: {
  registrations: "users/registrations",
  sessions: "users/sessions",
  omniauth_callbacks: "users/omniauth_callbacks",
  masquerades: "users/masquerades"
}

resource :user, path: I18n.t("routes.user") do
  scope module: :users do
    resources :connected_accounts
    resources :referrals, only: %i[index]
    resources :invitations, only: %i[index] do
      member do
        post :approve
        post :reject
      end
    end
    resources :membership_requests, only: %i[index create destroy]
  end
end
