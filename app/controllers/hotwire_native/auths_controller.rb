# frozen_string_literal: true

class HotwireNative::AuthsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:destroy]

  # Hotwire Native sign out
  def destroy
    return head :unauthorized unless user_signed_in?

    # Delete push device if provided (for push notifications)
    current_user.push_devices.find_by(token: params[:notification_token])&.destroy if params[:notification_token].present?

    sign_out(current_user)
    render json: {}
  end
end
