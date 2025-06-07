class Users::MasqueradesController < Devise::MasqueradesController
  before_action :authorize_admin, except: :back

  protected

  def authorize_admin
    redirect_to root_path unless current_user.admin?
  end

  def after_back_masquerade_path_for(_resource)
    Avo.configuration.root_path
  end
end
