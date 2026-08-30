# frozen_string_literal: true

class AddAdminGrantedAccessToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :admin_granted_access, :boolean, default: false, null: false
  end
end
