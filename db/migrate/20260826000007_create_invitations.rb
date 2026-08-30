# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[8.1]
  def up
    create_table :invitations do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :invited_by, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :email, null: false
      t.string :role, null: false, default: "member"
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :last_sent_at
      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, "lower(email)", name: "index_invitations_on_lower_email"
    add_index :invitations, [:organization_id, :email], unique: true

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO invitations (organization_id, invited_by_id, email, role, token, expires_at, last_sent_at, created_at, updated_at)
        SELECT access_requests.organization_id,
               CASE WHEN users.invited_by_type = 'User' THEN users.invited_by_id END,
               lower(users.email),
               'member',
               replace(gen_random_uuid()::text, '-', ''),
               CURRENT_TIMESTAMP + INTERVAL '14 days',
               access_requests.created_at,
               access_requests.created_at,
               access_requests.updated_at
        FROM access_requests
        INNER JOIN users ON users.id = access_requests.user_id
        WHERE access_requests.type = 'AccessRequest::InviteToOrganization'
          AND access_requests.status = 'pending'
      SQL

      execute "DELETE FROM access_requests WHERE type = 'AccessRequest::InviteToOrganization'"
    end
  end

  def down
    drop_table :invitations
  end
end
