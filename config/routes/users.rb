# frozen_string_literal: true

devise_for :users, controllers: {
  registrations: "users/registrations",
  sessions: "users/sessions",
  masquerades: "users/masquerades",
  confirmations: "users/confirmations"
}

devise_scope :user do
  get "/auth/:provider/callback", to: "users/omniauth_callbacks#callback", as: :omniauth_callback
  get "/users/invitation/accept", to: "users/invitations#new", as: :accept_user_invitation
  post "/users/invitation/accept", to: "users/invitations#create", as: :accept_user_invitation_create
end

resource :user, only: %i[show], path: I18n.t("routes.user") do
  scope module: :users do
    resources :notifications, only: %i[index]
    resources :connected_accounts
    resources :referrals, only: %i[index]
    namespace :organizations do
      resources :invitations, only: %i[index] do
        member do
          patch :approve
          patch :reject
        end
      end
      resources :membership_requests, only: %i[index create destroy]
    end
  end
end
