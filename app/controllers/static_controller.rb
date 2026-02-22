# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def sitemap
    expires_in 12.hours, public: true
  end

  def pricing; end

  def terms; end

  def privacy; end

  def refunds; end
end
