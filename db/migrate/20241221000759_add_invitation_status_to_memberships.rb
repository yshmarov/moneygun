class AddInvitationStatusToMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :memberships, :invitation_status, :string, default: "pending", null: false
  end
end
