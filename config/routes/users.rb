# frozen_string_literal: true

devise_for :users, controllers: {
  registrations: "users/registrations",
  sessions: "users/sessions",
  masquerades: "users/masquerades"
}

devise_scope :user do
  get "/auth/:provider/callback", to: "users/omniauth_callbacks#callback", as: :omniauth_callback
end

resource :user, only: %i[show], path: I18n.t("routes.user") do
  scope module: :users do
    resources :notifications, only: %i[index]
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
