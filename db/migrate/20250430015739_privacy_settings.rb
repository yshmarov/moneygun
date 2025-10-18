class PrivacySettings < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :privacy_setting, :string, default: 'private', null: false

    create_table :access_requests do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending'
      t.bigint :completed_by
      t.string :type
      t.json :resources

      t.timestamps
    end

    add_foreign_key :access_requests, :users, column: :completed_by
  end
end
