# frozen_string_literal: true

Rails.application.routes.draw do
  draw :users
  draw :organizations
  draw :admin
  draw :sso
  draw :scim

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

  # Defines the root path route ("/")
  root "static#index"
  get "sitemap.xml", to: "static#sitemap", defaults: { format: :xml }
  get "pricing", to: "static#pricing"
  get "terms", to: "static#terms"
  get "privacy", to: "static#privacy"
  get "refunds", to: "static#refunds"

  get "search", to: "search#index"
end
