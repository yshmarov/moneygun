# frozen_string_literal: true

class CreateOrganizationInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :organization_invitations, [:user_id, :organization_id], unique: true
  end
end
