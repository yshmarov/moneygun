# frozen_string_literal: true

class BackfillProjectMemberships < ActiveRecord::Migration[8.1]
  CONSTRAINT = "projects_membership_id_null"

  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE projects
        SET membership_id = memberships.id
        FROM memberships
        WHERE memberships.organization_id = projects.organization_id
          AND memberships.user_id = (
            SELECT organizations.owner_id
            FROM organizations
            WHERE organizations.id = projects.organization_id
          )
      SQL
    end

    add_check_constraint :projects, "membership_id IS NOT NULL", name: CONSTRAINT, validate: false
  end

  def down
    remove_check_constraint :projects, name: CONSTRAINT
  end
end
