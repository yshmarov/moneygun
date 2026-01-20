class ReplaceStatusWithSuspendedAtOnMemberships < ActiveRecord::Migration[8.1]
  def up
    add_column :memberships, :suspended_at, :datetime

    # Migrate existing suspended memberships
    execute <<-SQL
      UPDATE memberships SET suspended_at = updated_at WHERE status = 'suspended'
    SQL

    remove_index :memberships, :status
    remove_column :memberships, :status
  end

  def down
    add_column :memberships, :status, :string, null: false, default: "active"
    add_index :memberships, :status

    execute <<-SQL
      UPDATE memberships SET status = 'suspended' WHERE suspended_at IS NOT NULL
    SQL

    remove_column :memberships, :suspended_at
  end
end
