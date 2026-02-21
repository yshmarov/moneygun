# frozen_string_literal: true

class CreateNondisposableDisposableDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :nondisposable_disposable_domains do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :nondisposable_disposable_domains, :name, unique: true
  end
end
