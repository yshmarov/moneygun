# frozen_string_literal: true

devise_for :users, controllers: {
  registrations: "users/registrations",
  sessions: "users/sessions",
  masquerades: "users/masquerades",
  confirmations: "users/confirmations"
}

devise_scope :user do
  get "/auth/:provider/callback", to: "users/omniauth_callbacks#callback", as: :omniauth_callback
  post "/google_onetap_callback", to: "users/omniauth_callbacks#google_onetap", as: :google_onetap_callback
  get "/users/invitation/accept", to: "users/invitation_acceptances#new", as: :accept_user_invitation
  post "/users/invitation/accept", to: "users/invitation_acceptances#create", as: :accept_user_invitation_create
end

resource :user, only: %i[show edit update], path: I18n.t("routes.user") do
  scope module: :users do
    resources :notifications, only: %i[index]
    resources :identities
    resources :referrals, only: %i[index]

    namespace :organizations do
      # Invitations received BY user FROM organizations
      resources :received_invitations, only: %i[index show], path: "invitations" do
        member do
          patch :accept
          patch :decline
        end
      end

      # Join requests sent BY user TO organizations
      resources :sent_join_requests, only: %i[index create destroy], path: "join-requests"
    end
  end
end
