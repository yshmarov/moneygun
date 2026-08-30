# frozen_string_literal: true

class CreateAgreementEvidence < ActiveRecord::Migration[8.0]
  INITIAL_VERSIONS = [
    {
      agreement_key: "user_terms",
      version: "2026-08-30",
      acceptance_statement: "I accept the Moneygun Terms of Service and acknowledge the Privacy Notice.",
      documents: [
        { title: "Terms of Service", url: "https://example.com/terms" },
        { title: "Privacy Notice", url: "https://example.com/privacy" }
      ]
    },
    {
      agreement_key: "organization_dpa",
      version: "2026-08-30",
      acceptance_statement: "I accept the Moneygun Data Processing Agreement on behalf of this organization.",
      documents: [{ title: "Data Processing Agreement", url: "https://example.com/dpa" }]
    }
  ].freeze

  def up
    create_table :agreements_versions do |t|
      t.string :agreement_key, null: false
      t.string :version, null: false
      t.text :acceptance_statement, null: false
      t.json :documents, null: false, default: []
      t.timestamps
      t.index %i[agreement_key version], unique: true
    end

    create_table :agreements_acceptances do |t|
      t.references :agreement_version, null: false, index: false, foreign_key: { to_table: :agreements_versions }
      t.string :subject_key, null: false
      t.string :actor_key, null: false
      t.string :authority, null: false
      t.text :acceptance_statement, null: false
      t.string :locale, null: false
      t.datetime :accepted_at, null: false
      t.timestamps
      t.index %i[agreement_version_id subject_key], unique: true, name: "index_agreement_acceptances_on_version_and_subject"
      t.index :subject_key
    end

    version_model = Class.new(ActiveRecord::Base) { self.table_name = "agreements_versions" }
    INITIAL_VERSIONS.each { |attributes| version_model.create!(**attributes) }
  end

  def down
    drop_table :agreements_acceptances
    drop_table :agreements_versions
  end
end
