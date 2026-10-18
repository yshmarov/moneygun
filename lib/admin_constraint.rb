# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    Session.resume_from_cookie(request.cookie_jar[:session_token])&.user&.admin_access?
  end
end
