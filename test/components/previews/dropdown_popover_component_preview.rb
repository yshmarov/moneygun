# frozen_string_literal: true

class DropdownPopoverComponentPreview < ViewComponent::Preview
  # @label Default (end-aligned)
  def default
    render DropdownPopoverComponent.new do
      tag.li(tag.a("Edit"), role: "menuitem") +
        tag.li(tag.a("Delete"), role: "menuitem") +
        tag.li(tag.a("Share"), role: "menuitem")
    end
  end

  # @label Start-aligned
  def start_aligned
    render DropdownPopoverComponent.new(position: "dropdown-start") do
      tag.li(tag.a("Edit"), role: "menuitem") +
        tag.li(tag.a("Delete"), role: "menuitem") +
        tag.li(tag.a("Share"), role: "menuitem")
    end
  end

  # @label Bottom-aligned (default vertical)
  def bottom_aligned
    render DropdownPopoverComponent.new(position: "dropdown-bottom dropdown-end") do
      tag.li(tag.a("Edit"), role: "menuitem") +
        tag.li(tag.a("Delete"), role: "menuitem") +
        tag.li(tag.a("Share"), role: "menuitem")
    end
  end

  # @label Top-aligned
  def top_aligned
    render DropdownPopoverComponent.new(position: "dropdown-top dropdown-end") do
      tag.li(tag.a("Edit"), role: "menuitem") +
        tag.li(tag.a("Delete"), role: "menuitem") +
        tag.li(tag.a("Share"), role: "menuitem")
    end
  end

  # @label Custom button with text and icon
  def custom_button_with_text_and_icon
    render DropdownPopoverComponent.new(
      button_class: "btn btn-primary btn-sm",
      icon: tag.span("Actions", class: "mr-1") + tag.span("▼", class: "text-xs"),
      aria_label: "Actions menu"
    ) do
      tag.li(tag.a("Edit"), role: "menuitem") +
        tag.li(tag.a("Delete"), role: "menuitem") +
        tag.li(tag.a("Share"), role: "menuitem")
    end
  end
end
