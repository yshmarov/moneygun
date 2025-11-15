# frozen_string_literal: true

class EmptyStateComponent < ViewComponent::Base
  def initialize(title: "Nothing here yet", subtitle: "Come back soon", icon: nil)
    @title = title
    @subtitle = subtitle
    @icon = icon
  end

  attr_reader :title, :subtitle, :icon

  def icon_content
    return if icon.blank?

    if icon.match?(/svg/)
      helpers.inline_svg_tag icon, class: "w-10 h-10 size-10 text-base-content/50"
    elsif icon&.start_with?("http") || icon&.match?(/\.(png|jpg|webp|avif|gif)$/)
      image_tag icon, class: "w-10 h-10 rounded object-cover"
    else
      tag.span icon, class: "text-4xl"
    end
  end
end
