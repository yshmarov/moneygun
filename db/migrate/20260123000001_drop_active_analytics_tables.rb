# frozen_string_literal: true

class DropActiveAnalyticsTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :active_analytics_views_per_days do |t|
      t.datetime "created_at", precision: nil, null: false
      t.date "date", null: false
      t.string "page", null: false
      t.string "referrer_host"
      t.string "referrer_path"
      t.string "site", null: false
      t.bigint "total", default: 1, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["date", "site", "page"], name: "index_active_analytics_views_per_days_on_date_and_site_and_page"
      t.index ["date", "site", "referrer_host", "referrer_path"], name: "index_views_per_days_on_date_site_referrer_host_referrer_path"
    end

    drop_table :active_analytics_browsers_per_days do |t|
      t.datetime "created_at", null: false
      t.date "date", null: false
      t.string "name", null: false
      t.string "site", null: false
      t.bigint "total", default: 1, null: false
      t.datetime "updated_at", null: false
      t.string "version", null: false
      t.index ["date", "site", "name", "version"], name: "idx_on_date_site_name_version_eeccd0371c"
    end
  end
end
