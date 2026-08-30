# frozen_string_literal: true

class AddProjectMembershipForeignKey < ActiveRecord::Migration[8.1]
  CONSTRAINT = "projects_membership_id_null"

  disable_ddl_transaction!

  def up
    validate_check_constraint :projects, name: CONSTRAINT
    change_column_null :projects, :membership_id, false
    remove_check_constraint :projects, name: CONSTRAINT
  end

  def down
    change_column_null :projects, :membership_id, true
  end
end
