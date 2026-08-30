# frozen_string_literal: true

class AddDeletedAtToOrganizations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :organizations, :deleted_at, :datetime
    remove_index :organizations, :name, algorithm: :concurrently
    remove_index :organizations, :owner_id, algorithm: :concurrently
    add_index :organizations, :name, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organizations, :owner_id, where: "deleted_at IS NULL", algorithm: :concurrently
    add_index :organizations, :deleted_at, where: "deleted_at IS NOT NULL", algorithm: :concurrently
  end
end
