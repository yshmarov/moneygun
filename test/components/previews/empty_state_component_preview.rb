# frozen_string_literal: true

class EmptyStateComponentPreview < ViewComponent::Preview
  def text
    render EmptyStateComponent.new(title: "No results found", subtitle: "Try adjusting your search terms", icon: "🔍")
  end

  def svg
    render EmptyStateComponent.new(title: "No results found", subtitle: "Try adjusting your search terms", icon: "svg/magnifying-glass.svg")
  end

  def image_url
    render EmptyStateComponent.new(title: "No results found", subtitle: "Try adjusting your search terms", icon: "https://placehold.co/48x48")
  end

  def no_icon
    render EmptyStateComponent.new(title: "No results found", subtitle: "Try adjusting your search terms")
  end
end
