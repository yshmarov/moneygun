# frozen_string_literal: true

class CreateDataExports < ActiveRecord::Migration[8.1]
  def change
    create_table :data_exports do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :membership, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  end
end
