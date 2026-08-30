# frozen_string_literal: true

class HardenCoreDatabaseConstraints < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_check_constraint :organizations, "name IS NOT NULL", name: "organizations_name_null", validate: false
    validate_check_constraint :organizations, name: "organizations_name_null"
    change_column_null :organizations, :name, false
    remove_check_constraint :organizations, name: "organizations_name_null"

    add_index :access_requests, :completed_by, algorithm: :concurrently
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email", algorithm: :concurrently
  end

  def down
    remove_index :users, name: "index_users_on_lower_email", algorithm: :concurrently
    remove_index :access_requests, :completed_by, algorithm: :concurrently

    change_column_null :organizations, :name, true
  end
end
