# frozen_string_literal: true

class AddMetadataToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :metadata, :jsonb, default: {}, null: false
  end
end
