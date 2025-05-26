class CreateFileContents < ActiveRecord::Migration[7.1]
  def change
    create_table :file_contents do |t|
      t.references :file_system_node, null: false, foreign_key: true, index: { unique: true }
      t.string :content_type
      t.string :storage_type, null: false, default: 'blob'
      t.binary :blob_data, limit: 16.megabytes
      t.string :s3_key
      t.text :file_path
      t.string :checksum
      t.bigint :content_size, default: 0

      t.timestamps
    end

    add_index :file_contents, :storage_type
    add_index :file_contents, :s3_key, unique: true, where: "s3_key IS NOT NULL"
    add_index :file_contents, :file_path, unique: true, where: "file_path IS NOT NULL"
    add_index :file_contents, :checksum
  end
end
