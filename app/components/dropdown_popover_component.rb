# frozen_string_literal: true

# CSS-only dropdown using daisyUI classes
# No JavaScript required - uses CSS :focus for open/close
class DropdownPopoverComponent < ViewComponent::Base
  def initialize(button_class: nil, icon: nil, aria_label: "Open menu", position: "dropdown-end")
    @button_class = button_class
    @icon = icon
    @aria_label = aria_label
    @position = position
  end

  private

  attr_reader :button_class, :icon, :aria_label, :position

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
