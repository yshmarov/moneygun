module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :masquerade_user!
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end

  # https://github.com/scambra/devise_invitable
  # def after_invite_path_for(resource)
  #   edit_user_invitation_path(resource)
  # end
end
