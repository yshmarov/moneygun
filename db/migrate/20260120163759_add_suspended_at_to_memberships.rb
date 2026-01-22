# frozen_string_literal: true

class AddSuspendedAtToMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :memberships, :suspended_at, :datetime
    add_index :memberships, :suspended_at

    # Allow null user_id for archived memberships
    change_column_null :memberships, :user_id, true

    # Remove existing unique indexes and add partial unique indexes
    # that only apply when user_id is not null
    remove_index :memberships, %i[organization_id user_id], name: "index_memberships_on_organization_id_and_user_id"
    remove_index :memberships, %i[user_id organization_id], name: "index_memberships_on_user_id_and_organization_id"

    add_index :memberships, %i[organization_id user_id],
              unique: true,
              where: "user_id IS NOT NULL",
              name: "index_memberships_on_org_and_user_unique"
    add_index :memberships, %i[user_id organization_id],
              unique: true,
              where: "user_id IS NOT NULL",
              name: "index_memberships_on_user_and_org_unique"
  end
end
