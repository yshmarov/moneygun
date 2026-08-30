# frozen_string_literal: true

scope path: "scim/v2" do
  mount Scimitar::Engine, at: "/"
  get "Users", to: "scim/users#index", as: :scim_users
  get "Users/:id", to: "scim/users#show", as: :scim_user
  post "Users", to: "scim/users#create"
  put "Users/:id", to: "scim/users#replace"
  patch "Users/:id", to: "scim/users#update"
  delete "Users/:id", to: "scim/users#destroy"
end
