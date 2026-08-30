# frozen_string_literal: true

class RemoveLegacyAuthentication < ActiveRecord::Migration[8.1]
  LEGACY_COLUMNS = %i[
    encrypted_password reset_password_token reset_password_sent_at remember_created_at
    confirmation_token confirmed_at confirmation_sent_at unconfirmed_email
    invitation_token invitation_created_at invitation_sent_at invitation_accepted_at
    invitation_limit invitations_count invited_by_type invited_by_id
  ].freeze

  def up
    safety_assured do
      drop_table :identities
      remove_columns :users, *LEGACY_COLUMNS
    end
  end

  def down
    safety_assured do
      create_table :identities do |t|
        t.references :user, null: false, foreign_key: true
        t.string :provider
        t.string :uid
        t.jsonb :payload
        t.text :access_token
        t.text :refresh_token
        t.datetime :expires_at
        t.datetime :refresh_token_invalidated_at
        t.timestamps
      end

      add_column :users, :encrypted_password, :string, null: false, default: ""
      (LEGACY_COLUMNS - [:encrypted_password]).each { |column| add_column :users, column, legacy_type(column) }
    end
  end

  private

  def legacy_type(column)
    return :integer if %i[invitation_limit invitations_count].include?(column)

    column.to_s.end_with?("_at") ? :datetime : :string
  end
end
