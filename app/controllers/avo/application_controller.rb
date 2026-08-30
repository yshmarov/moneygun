# frozen_string_literal: true

class Avo::ApplicationController < Avo::BaseApplicationController
  def current_user
    Current.user || authenticate_from_cookie
  end

  private

  def authenticate_from_cookie
    session_record = Session.resume_from_cookie(cookies[:session_token], cookies: cookies)
    return unless session_record

    Current.session = session_record
    Current.user
  end
end
