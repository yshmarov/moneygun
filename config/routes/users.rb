# frozen_string_literal: true

resource :session, only: %i[new create destroy] do
  resource :magic_link, only: %i[show create], module: :sessions
  resource :two_factor, only: %i[new create], module: :sessions, controller: "two_factor"
end

# Keep the former sign-in URLs working while applications migrate bookmarks.
get "/users/sign_in", to: "sessions#new", as: :new_user_session
delete "/users/sign_out", to: "sessions#destroy", as: :destroy_user_session

resource :sudo, only: %i[new create], module: :users, controller: "sudo" do
  post :resend
end

resource :onboarding, controller: "onboarding", only: [] do
  get :terms
  patch :accept_terms
  get :profile
  patch :update_profile
end

resource :user, only: %i[show edit update destroy], path: I18n.t("routes.user") do
  scope module: :users do
    resource :email_change, only: %i[new create show update]
    resource :two_factor, only: %i[show new create edit destroy], controller: "two_factor"
    resources :notifications, only: %i[index]
    resources :sessions, only: %i[index destroy] do
      collection do
        delete :all, action: :destroy_all, as: :destroy_all
      end
    end
    resources :invitations, only: %i[index show] do
      member do
        patch :accept
        patch :decline
      end
    end
    resources :referrals, only: %i[index]

    namespace :organizations do
      resources :sent_join_requests, only: %i[index create destroy], path: "join-requests"
    end
  end
end
