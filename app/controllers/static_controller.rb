class StaticController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    redirect_to organizations_path if current_user
  end

  def pricing
  end

  def terms
  end

  def privacy
  end
end
