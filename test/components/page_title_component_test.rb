# frozen_string_literal: true

require "test_helper"

class PageTitleComponentTest < ViewComponent::TestCase
  test "renders a linked trail and current-page heading" do
    render_inline PageTitleComponent.new(["Projects", "/projects"], "Roadmap", back_to: "/projects")

    assert_selector "a[href='/projects']", minimum: 2
    assert_selector "h1", text: "Roadmap"
    assert_selector "nav[aria-label='Breadcrumb'] li[aria-current='page']"
  end
end
