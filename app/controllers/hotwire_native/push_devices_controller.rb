# frozen_string_literal: true

class HotwireNative::PushDevicesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  # Platform mapping from mobile app format to action_push_native format
  PLATFORM_MAP = {
    "iOS" => "apple",
    "fcm" => "google"
  }.freeze

  def create
    current_user.push_devices.find_or_create_by!(token: params[:token]) do |device|
      device.platform = PLATFORM_MAP.fetch(params[:platform], params[:platform])
    end
    render json: {}, status: :created
  end

  def destroy
    device = current_user.push_devices.find_by(token: params[:token])

    if device
      device.destroy
      render json: {}
    else
      head :not_found
    end
  end
end
