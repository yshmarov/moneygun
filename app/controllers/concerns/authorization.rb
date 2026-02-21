# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  include Pundit::Authorization

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def user_not_authorized
    flash[:alert] = t("shared.errors.not_authorized")
    redirect_to(request.referer || default_authenticated_path)
  end
end
