# frozen_string_literal: true

class AddEnterpriseIdentity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :sso_connections do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :idp_entity_id
      t.string :idp_sso_url
      t.text :idp_cert
      t.boolean :enabled, null: false, default: false
      t.boolean :enforced, null: false, default: false
      t.boolean :jit_provisioning, null: false, default: false
      t.string :default_membership_role, null: false, default: "member"
      t.datetime :last_login_at
      t.timestamps
    end

    create_table :sso_domains do |t|
      t.references :sso_connection, null: false, foreign_key: { on_delete: :cascade }
      t.string :domain, null: false
      t.string :verification_token, null: false
      t.datetime :verified_at
      t.timestamps

      t.index %i[sso_connection_id domain], unique: true
      t.index :domain, unique: true, where: "verified_at IS NOT NULL", name: "index_sso_domains_on_verified_domain"
    end

    create_table :saml_auth_requests do |t|
      t.references :sso_connection, null: false, foreign_key: { on_delete: :cascade }
      t.string :request_id, null: false, index: { unique: true }
      t.datetime :expires_at, null: false, index: true
      t.timestamps
    end

    create_table :scim_connections do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.string :token_digest, null: false, index: { unique: true }
      t.string :token_last_four
      t.boolean :enabled, null: false, default: true
      t.string :default_membership_role, null: false, default: "member"
      t.datetime :last_request_at
      t.timestamps
    end

    add_column :memberships, :display_name, :string
    add_column :memberships, :provisioned_via, :string, null: false, default: "manual"
    add_column :memberships, :scim_external_id, :string
    add_index :memberships, %i[organization_id scim_external_id], unique: true,
              where: "scim_external_id IS NOT NULL", name: "index_memberships_on_organization_id_and_scim_external_id",
              algorithm: :concurrently
    add_column :sessions, :authentication, :jsonb, null: false, default: {}
  end
end
