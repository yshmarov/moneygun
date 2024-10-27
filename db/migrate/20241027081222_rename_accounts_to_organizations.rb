class RenameOrganizationsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    rename_table :organizations, :organizations
    rename_table :organization_users, :memberships
    rename_column :memberships, :organization_id, :organization_id
    rename_column :inboxes, :organization_id, :organization_id
  end
end
