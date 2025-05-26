class CreateFileSystemNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :file_system_nodes do |t|
      t.string :name, null: false
      t.text :path, null: false
      t.string :node_type, null: false
      t.references :parent, null: true, foreign_key: { to_table: :file_system_nodes }
      t.bigint :size, default: 0
      t.text :description

      t.timestamps
    end

    add_index :file_system_nodes, :path, unique: true
    add_index :file_system_nodes, :node_type
    add_index :file_system_nodes, [:parent_id, :name], unique: true
  end
end
