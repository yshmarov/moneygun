# frozen_string_literal: true

require "test_helper"

class EmptyStateComponentTest < ViewComponent::TestCase
  def test_component_renders_something_useful
    render_inline EmptyStateComponent.new(title: "No projects", subtitle: "Create the first project", icon: "svg/briefcase.svg")

    assert_selector "h2", text: "No projects"
    assert_text "Create the first project"
    assert_selector ".icon--briefcase"
  end
end
