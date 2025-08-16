# frozen_string_literal: true

# <%= render EmptyStateComponent.new(title: "No submissions yet") do |c| %>
#   <% c.with_icon do %>
#     <%= inline_svg_tag "svg/home.svg", class: "w-10 h-10 text-base-content/50" %>
#   <% end %>
# <% end %>
class EmptyStateComponent < ViewComponent::Base
  renders_one :icon

  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = subtitle
  end
end
