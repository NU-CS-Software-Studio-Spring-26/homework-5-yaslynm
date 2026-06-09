class AddHighPriorityToTodos < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :high_priority, :boolean
  end
end
