# frozen_string_literal: true

class EmptyStateComponent < ViewComponent::Base
  def initialize(title: "Nothing here yet", subtitle: "Come back soon", icon: nil)
    @title = title
    @subtitle = subtitle
    @icon = icon
  end

  attr_reader :title, :subtitle, :icon

  def icon_content
    helpers.resolve_icon(icon, classes: "w-10 h-10 size-10 text-base-content/50")
  end
end
