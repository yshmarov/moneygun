# frozen_string_literal: true

class HotwireNative::Android::PathConfigurationsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    render json: {}
  end
end
