class TabsComponentPreview < ViewComponent::Preview
  def default
    render TabsComponent.new(active_tab: :custom, tabs: tabs_with_custom_content)
  end

  private

  def tabs_with_custom_content
    [
      { key: :normal, label: "Normal Tab", path: "#normal" },
      {
        key: :custom,
        path: "#custom",
        content: content_tag(:div, class: "flex items-center gap-2") do
          content_tag(:span, "🌟", class: "") +
          content_tag(:span, "Special", class: "font-bold") +
          content_tag(:span, "NEW", class: "du-badge du-badge-xs du-badge-accent")
        end
      },
      { key: :another, label: "With Badge", path: "#another", badge_count: 10 }
    ]
  end
end
