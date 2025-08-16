class PageComponentPreview < ViewComponent::Preview
  def default
    component = PageComponent.new(
      title: "Title",
      subtitle: "Subtitle",
      full_width: true
    )

    component.with_action_list do
      content_tag(:li, "Link", class: "du-btn du-btn-link") +
      content_tag(:button, "Button", class: "du-btn du-btn-primary")
    end

    render component do
      "Content"
    end
  end
end
