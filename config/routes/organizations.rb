# frozen_string_literal: true

namespace :public do
  resources :organizations, only: %i[index show]
end

resources :organizations, path: I18n.t("routes.organizations") do
  scope module: :organizations do
    resource :logo, only: :destroy
    namespace :onboarding do
      resource :profile, only: %i[show update]
      resource :team, only: :show
      resource :subscription, only: :show
    end
    resource :sso_connection, only: %i[show create update destroy] do
      resources :sso_domains, only: %i[create destroy] do
        post :verify, on: :member
      end
    end
    resource :scim_connection, only: %i[show create update destroy]
    resources :audit_logs, only: :index
    resources :data_exports, only: %i[index create show]
    resource :transfer, only: %i[show update]
    resources :memberships, except: %i[new create], path: I18n.t("routes.memberships") do
      patch :reactivate, on: :member
    end
    resources :invitations, except: %i[edit update] do
      post :resend, on: :member
    end
    resources :received_join_requests, only: %i[index], path: "join-requests" do
      member do
        post :approve
        post :reject
      end
    end

    get "subscriptions", to: "subscriptions#index"
    get "subscriptions/checkout", to: "subscriptions#checkout"
    get "subscriptions/success", to: "subscriptions#success"
    post "subscriptions/billing_portal", to: "subscriptions#billing_portal"

    # put application-specific resources scoped to the organization below
    resources :projects
    get "dashboard", to: "dashboard#index"
    get "paywalled_page", to: "dashboard#paywalled_page"
  end
end
