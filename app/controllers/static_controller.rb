# frozen_string_literal: true

class StaticController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_authenticated_user, only: :index

  def index; end

  def sitemap
    expires_in 12.hours, public: true
  end

  def pricing; end

  def terms; end

  def privacy; end

  def refunds; end
end
