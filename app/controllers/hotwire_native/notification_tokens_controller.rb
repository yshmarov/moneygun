# frozen_string_literal: true

class HotwireNative::NotificationTokensController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def create
    current_user.notification_tokens.find_or_create_by!(
      token: params[:token],
      platform: params[:platform]
    )
    render json: {}, status: :created
  end

  def destroy
    current_user.notification_tokens.find_by!(token: params[:token]).destroy
    render json: {}
  end
end
