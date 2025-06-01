module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || organizations_path
  end
end
