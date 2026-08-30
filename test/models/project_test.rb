# frozen_string_literal: true

require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "requires the creator membership to belong to the project organization" do
    project = Project.new(
      name: "Cross-tenant project",
      organization: organizations(:one),
      membership: memberships(:two)
    )

    assert_not project.valid?
    assert project.errors.added?(:membership, :same_organization)
  end
end
