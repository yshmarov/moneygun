# frozen_string_literal: true

class CreatePgheroStats < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_stat_statements"

    # PgHero keys and prunes its history by captured_at; it never reads Rails timestamps.
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :pghero_query_stats do |t|
      t.text :database
      t.text :user
      t.text :query
      t.integer :query_hash, limit: 8
      t.float :total_time
      t.integer :calls, limit: 8
      t.timestamp :captured_at
    end
    add_index :pghero_query_stats, %i[database captured_at]

    create_table :pghero_space_stats do |t|
      t.text :database
      t.text :schema
      t.text :relation
      t.integer :size, limit: 8
      t.timestamp :captured_at
    end
    add_index :pghero_space_stats, %i[database captured_at]
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
