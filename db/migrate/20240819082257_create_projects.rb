class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
    add_index :projects, [ :name, :organization_id ], unique: true
  end
end
