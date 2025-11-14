class AddUniqueIndexToAccessRequestsUserAndOrganization < ActiveRecord::Migration[8.0]
  def change
    add_index :access_requests, [:user_id, :organization_id], unique: true
  end
end
