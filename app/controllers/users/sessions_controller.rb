class Users::SessionsController < Devise::SessionsController
  rate_limit to: 50, within: 3.minutes, only: :create, with: -> { redirect_to new_user_session_url, alert: "Try again later." }
end
