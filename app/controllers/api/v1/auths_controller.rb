# frozen_string_literal: true

class HotwireNative::V1::AuthsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:destroy]

  # Hotwire Native sign out
  def destroy
    return head :unauthorized unless user_signed_in?

    # Delete notification token if provided (for push notifications)
    current_user.notification_tokens.find_by(token: params[:notification_token])&.destroy if params[:notification_token].present? && current_user.respond_to?(:notification_tokens)

    sign_out(current_user)
    render json: {}
  end
end
