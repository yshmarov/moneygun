class StaticController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def index
  end

  def dashboard
  end

  def pricing
  end

  def terms
  end

  def privacy
  end
end
