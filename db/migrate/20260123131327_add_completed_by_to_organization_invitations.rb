# frozen_string_literal: true

class AddCompletedByToOrganizationInvitations < ActiveRecord::Migration[8.1]
  def change
    add_reference :organization_invitations, :completed_by, foreign_key: { to_table: :users }
  end
end
