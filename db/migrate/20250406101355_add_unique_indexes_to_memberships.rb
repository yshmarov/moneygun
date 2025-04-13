class AddUniqueIndexesToMemberships < ActiveRecord::Migration[8.0]
  def change
    add_index :memberships, [ :user_id, :organization_id ], unique: true
    add_index :memberships, [ :organization_id, :user_id ], unique: true
  end
end
