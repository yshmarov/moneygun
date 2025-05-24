require "test_helper"

class PageComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    assert_match(
      %(Hello, components!),
      render_inline(PageComponent.new(title: "Hello, components!")).to_html
    )
  end
end
