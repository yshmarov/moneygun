# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :redirect_if_authenticated, only: %i[index pricing]

  def index; end

  def pricing; end

  def terms; end

  def privacy; end

  def refunds; end

  def reset_app
    # Hotwire Native needs an empty page to route authentication and reset the app.
    # We can't head: 200 because we also need the Turbo JavaScript in <head>.
  end

  private

  def redirect_if_authenticated
    redirect_to organizations_path if current_user
  end
end
