# frozen_string_literal: true

require "test_helper"

class SectionComponentTest < ViewComponent::TestCase
  def test_component_renders_with_title
    render_inline(SectionComponent.new(title: "Page Title"))

    assert_selector "h1", text: "Page Title"
    assert_selector "section.space-y-4"
  end

  def test_component_renders_with_subtitle
    render_inline(SectionComponent.new(title: "Page Title", subtitle: "Page subtitle"))

    assert_selector "h1", text: "Page Title"
    assert_selector "p", text: "Page subtitle"
  end

  def test_component_renders_with_full_width
    render_inline(SectionComponent.new(title: "Page Title"))

    assert_selector "section", class: "max-w-7xl"
  end

  def test_component_renders_with_action_list
    component = SectionComponent.new(title: "Page Title")
    component.with_action_list { "Action Button" }

    render_inline(component)

    assert_text "Action Button"
    assert_selector ".whitespace-nowrap"
  end

  def test_component_renders_without_title
    render_inline(SectionComponent.new)

    assert_no_selector "h1"
    assert_selector "section"
  end

  def test_component_renders_content
    component = SectionComponent.new(title: "Page Title")

    render_inline(component) { "Page content here" }

    assert_text "Page content here"
  end
end
