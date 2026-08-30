# frozen_string_literal: true

class AddAccountAndMembershipLifecycle < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :users, :banned_at, :datetime
    add_column :users, :marketing_consent_at, :datetime
    add_column :users, :metadata, :jsonb, default: {}, null: false
    add_column :users, :onboarding_completed_at, :datetime
    add_column :users, :redacted_at, :datetime

    add_index :users, :banned_at, where: "banned_at IS NOT NULL", algorithm: :concurrently
    add_index :invitations, :expires_at, algorithm: :concurrently

    safety_assured do
      change_column_default :memberships, :provisioned_via, from: "manual", to: "invitation"
      change_column_null :audit_logs, :organization_id, true
    end
  end
end
