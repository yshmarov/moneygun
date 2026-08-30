# frozen_string_literal: true

class EmptyStateComponent < ApplicationComponent
  def initialize(title: I18n.t("shared.empty_state.title"), subtitle: I18n.t("shared.empty_state.subtitle"), icon: nil)
    @title = title
    @subtitle = subtitle
    @icon = icon
  end

  attr_reader :title, :subtitle, :icon

  def icon_content
    return if icon.blank?

    if icon.include?("svg")
      helpers.resolve_icon(icon, classes: "size-8 sm:size-10 text-base-content/30")
    elsif icon.start_with?("http") || icon.match?(/\.(png|jpg|webp|avif|gif)$/)
      helpers.resolve_icon(icon, classes: "w-10 h-10 rounded object-cover")
    else
      tag.span icon, class: "text-4xl"
    end
  end
end
