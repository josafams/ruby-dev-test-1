# frozen_string_literal: true

class AddChildrenCountToFileSystemNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :file_system_nodes, :children_count, :integer, default: 0, null: false
    add_index :file_system_nodes, :children_count

    # Atualizar contadores existentes
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE file_system_nodes 
          SET children_count = (
            SELECT COUNT(*) 
            FROM file_system_nodes children 
            WHERE children.parent_id = file_system_nodes.id
          )
        SQL
      end
    end
  end
end 