class RemoveResourcesFromAccessRequests < ActiveRecord::Migration[8.0]
  def change
    remove_column :access_requests, :resources, :jsonb
  end
end
