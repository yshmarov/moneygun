class AddFieldsToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :description, :text, if_not_exists: true
    add_column :projects, :status, :string, default: "planning", if_not_exists: true
    add_column :projects, :priority, :string, default: "medium", if_not_exists: true
    add_column :projects, :start_date, :date, if_not_exists: true
    add_column :projects, :due_date, :date, if_not_exists: true
    add_column :projects, :scheduled_at, :datetime, if_not_exists: true
    add_column :projects, :budget, :decimal, precision: 10, scale: 2, if_not_exists: true
    add_column :projects, :is_active, :boolean, default: true, if_not_exists: true
    add_column :projects, :category, :string, if_not_exists: true
    add_column :projects, :tags, :text, array: true, default: [], if_not_exists: true
  end
end
