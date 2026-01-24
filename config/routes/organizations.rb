# frozen_string_literal: true

# Browse discoverable organizations
resources :organizations, only: %i[index show]

# User's member organizations list (at /me/organizations)
resource :user, only: [], path: I18n.t("routes.user") do
  resources :organizations, only: %i[index new create], path: I18n.t("routes.organizations"), controller: "user/organizations"
end

# Organization-scoped resources (for members, at /organizations/:id/...)
resources :organizations, only: %i[edit update destroy], path: I18n.t("routes.organizations"), controller: "user/organizations" do
  scope module: :organizations do
    resource :transfer, only: %i[show update]
    resources :memberships, except: %i[new create], path: I18n.t("routes.memberships")
    resources :sent_invitations, except: %i[edit update], path: "invitations"
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
