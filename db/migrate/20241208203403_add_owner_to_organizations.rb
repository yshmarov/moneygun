class AddOwnerToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_reference :organizations, :owner, foreign_key: { to_table: :users }

    Organization.all.each do |organization|
      user = organization.memberships.admin.first&.user
      organization.update(owner: user)
    end

    change_column_null :organizations, :owner_id, false
  end
end
