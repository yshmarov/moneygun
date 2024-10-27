class CreateInboxes < ActiveRecord::Migration[8.0]
  def change
    create_table :inboxes do |t|
      t.string :name, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
    add_index :inboxes, [ :name, :organization_id ], unique: true
  end
end
