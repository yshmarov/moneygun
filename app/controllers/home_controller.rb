# frozen_string_literal: true

class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    if user_signed_in?
      redirect_to default_authenticated_path, allow_other_host: false
    else
      redirect_to helpers.marketing_website_url, allow_other_host: true
    end
  end
end
