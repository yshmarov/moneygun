devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }

resource :user do
  scope module: :users do
    # B2B-only routes
    constraints(lambda { |request| Rails.application.config_for(:settings).dig(:app_features, :b2b) == true }) do
      resources :invitations, only: %i[index] do
        member do
          post :approve
          post :reject
        end
      end
      resources :membership_requests, only: %i[index create destroy]
    end
  end
end
