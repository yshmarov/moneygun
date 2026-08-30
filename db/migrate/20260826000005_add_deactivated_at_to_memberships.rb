# frozen_string_literal: true

class AddDeactivatedAtToMemberships < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :memberships, :deactivated_at, :datetime
    add_index :memberships, [:organization_id, :deactivated_at], algorithm: :concurrently
  end
end
