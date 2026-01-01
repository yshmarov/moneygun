# frozen_string_literal: true

class PushNotificationsController < ApplicationController
  before_action :authenticate_user!

  def test
    if current_user.push_devices.any?
      TestPushNotifier.deliver_later(current_user)
      redirect_to root_path, notice: t(".success")
    else
      redirect_to root_path, alert: t(".no_devices")
    end
  end
end
