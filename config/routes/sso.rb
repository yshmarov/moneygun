# frozen_string_literal: true

resource :sso, only: %i[show new create], controller: "sessions/sso", path: "sso"
match "auth/saml/callback", to: "sessions/sso#callback", via: %i[get post], as: :sso_callback
get "auth/failure", to: "sessions/sso#failure", as: :sso_failure

if Rails.env.local?
  scope path: "dev/saml", module: :dev, as: :dev_saml do
    get "metadata", to: "saml_idp#metadata"
    match "sso", to: "saml_idp#new", via: %i[get post]
    post "sign-in", to: "saml_idp#create", as: :sign_in
  end
end
