class EmptyStateComponentPreview < ViewComponent::Preview
  def default
    render EmptyStateComponent.new(title: "No results found", subtitle: "Try adjusting your search terms") do |c|
      c.with_icon do
        image_tag "https://placehold.co/48x48", class: "size-12 mx-auto"
      end
    end
  end
end
