# frozen_string_literal: true

class DropAccessRequests < ActiveRecord::Migration[8.1]
  def change
    drop_table :access_requests do |t|
      t.bigint "completed_by"
      t.datetime "created_at", null: false
      t.bigint "organization_id", null: false
      t.string "status", default: "pending", null: false
      t.string "type"
      t.datetime "updated_at", null: false
      t.bigint "user_id", null: false
      t.index ["organization_id"], name: "index_access_requests_on_organization_id"
      t.index ["user_id", "organization_id"], name: "index_access_requests_on_user_id_and_organization_id", unique: true
      t.index ["user_id"], name: "index_access_requests_on_user_id"
    end
  end
end
