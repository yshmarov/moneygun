# frozen_string_literal: true

class DiscoversController < ApplicationController
  def show
    @organizations = Organization.not_privacy_setting_private
  end
end
