# frozen_string_literal: true

class DropdownPopoverComponentPreview < ViewComponent::Preview
  def default
    render DropdownPopoverComponent.new do
      tag.li("Edit", role: "menuitem") +
        tag.li("Delete", role: "menuitem") +
        tag.li("Share", role: "menuitem")
    end
  end

  def open_by_default
    render DropdownPopoverComponent.new(open: true) do
      tag.li("Edit", role: "menuitem") +
        tag.li("Delete", role: "menuitem") +
        tag.li("Share", role: "menuitem")
    end
  end

  def custom_placement
    render DropdownPopoverComponent.new(placement: "right left") do
      tag.li("Edit", role: "menuitem") +
        tag.li("Delete", role: "menuitem") +
        tag.li("Share", role: "menuitem")
    end
  end

  def custom_button_with_text_and_icon
    render DropdownPopoverComponent.new(
      button_class: "btn btn-primary btn-sm",
      icon: tag.span("Actions", class: "mr-1") + tag.span("▼", class: "text-xs"),
      aria_label: "Actions menu"
    ) do
      tag.li("Edit", role: "menuitem") +
        tag.li("Delete", role: "menuitem") +
        tag.li("Share", role: "menuitem")
    end
  end
end
