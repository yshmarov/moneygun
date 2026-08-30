# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      redirect_to default_authenticated_path, allow_other_host: false
    else
      redirect_to new_session_path
    end
  end
end
