class PageComponentPreview < ViewComponent::Preview
  def default
    component = PageComponent.new(
      title: 'Title',
      subtitle: 'Subtitle',
      full_width: true
    )

    component.with_action_list do
      content_tag(:li, 'Link', class: 'btn btn-link') +
      content_tag(:button, 'Button', class: 'btn btn-primary')
    end

    render component do
      'Content'
    end
  end
end
