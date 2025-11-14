# frozen_string_literal: true

class DeliveryMethods::TurboStream < ApplicationDeliveryMethod
  def deliver
    return unless recipient.is_a?(User)

    notification.broadcast_update_to_bell
    notification.broadcast_prepend_to_index_list
  end
end
