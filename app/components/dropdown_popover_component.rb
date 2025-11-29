# frozen_string_literal: true

class DropdownPopoverComponent < ViewComponent::Base
  def initialize(placement: "bottom-start top-start", button_class: nil, icon: nil, aria_label: "Open menu", open: false)
    @placement = placement
    @button_class = button_class
    @icon = icon
    @aria_label = aria_label
    @open = open
  end

  private

  attr_reader :placement, :button_class, :icon, :aria_label, :open

  def default_button_class
    "btn btn-ghost btn-sm btn-circle"
  end

  def button_classes
    button_class || default_button_class
  end

  def default_icon
    helpers.inline_svg_tag("svg/ellipsis-vertical.svg", class: "size-4")
  end

  def icon_content
    icon || default_icon
  end
end
