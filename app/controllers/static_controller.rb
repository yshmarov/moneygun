class StaticController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_authenticated, only: %i[index pricing]

  def index
  end

  def schedule_something
    HelloWorldJob.perform_later
  end

  def pricing
  end

  def terms
  end

  def privacy
  end

  private

  def redirect_if_authenticated
    redirect_to organizations_path if current_user
  end
end
