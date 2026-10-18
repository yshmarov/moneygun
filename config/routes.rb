# frozen_string_literal: true

Rails.application.routes.draw do
  draw :users
  draw :organizations
  draw :admin
  draw :sso
  draw :scim

  direct :rails_storage_redirect_without_filename do |model, options|
    expires_in = options.delete(:expires_in) { ActiveStorage.urls_expire_in }
    expires_at = options.delete(:expires_at)

    if model.respond_to?(:signed_id)
      route_for(:rails_service_blob, model.signed_id(expires_in:, expires_at:), "file", options)
    else
      route_for(:rails_blob_representation, model.blob.signed_id(expires_in:, expires_at:), model.variation.key, "file", options)
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  post "csp-reports", to: "csp_reports#create"

  get "agreements/user_terms", to: "agreements/acceptances#show", defaults: { agreement_key: "user_terms" }, as: :user_terms_agreement
  post "agreements/user_terms", to: "agreements/acceptances#create", defaults: { agreement_key: "user_terms" }, as: :accept_user_terms_agreement
  get "organizations/:organization_id/agreements/dpa", to: "agreements/acceptances#show", defaults: { agreement_key: "organization_dpa" }, as: :organization_dpa_agreement
  post "organizations/:organization_id/agreements/dpa", to: "agreements/acceptances#create", defaults: { agreement_key: "organization_dpa" }, as: :accept_organization_dpa_agreement

  root "home#index"
  get "pricing", to: "static#pricing"
  get "terms", to: "static#terms"
  get "privacy", to: "static#privacy"
  get "refunds", to: "static#refunds"

  get "search", to: "search#index"
end
