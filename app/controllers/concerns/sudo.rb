# frozen_string_literal: true

module Sudo
  extend ActiveSupport::Concern

  SUDO_DURATION = 30.minutes

  included do
    helper_method :sudo_active?
  end

  private

  def require_sudo(reason = nil)
    return if sudo_active?

    session[:sudo_return_to] = sudo_return_to
    session[:sudo_reason] = reason
    redirect_to new_sudo_path
  end

  def sudo_active?
    return false unless current_user && session[:sudo_user_id] == current_user.id

    session[:sudo_at].present? && Time.zone.at(session[:sudo_at].to_i) > SUDO_DURATION.ago
  end

  def start_sudo!
    session[:sudo_at] = Time.current.to_i
    session[:sudo_user_id] = current_user.id
  end

  def sudo_return_to
    return request.fullpath if request.get? || request.head?

    url_from(request.referer) || default_authenticated_path
  end
end
