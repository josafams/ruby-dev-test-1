require 'rails_helper'

RSpec.describe FileSystemNode, type: :model do
  let(:root_directory) { create(:directory, name: 'root') }
  let(:subdirectory) { create(:directory, name: 'documents', parent: root_directory) }
  let(:file_node) { create(:file_node, name: 'readme.txt', parent: subdirectory) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      node = build(:file_system_node, name: 'test', node_type: FileSystemNode::DIRECTORY_TYPE)
      expect(node).to be_valid
    end

    it 'requires name' do
      node = build(:file_system_node, name: nil)
      expect(node).not_to be_valid
    end

    it 'requires unique path' do
      create(:file_system_node, name: 'unique', node_type: FileSystemNode::DIRECTORY_TYPE)
      duplicate = build(:file_system_node, name: 'unique', node_type: FileSystemNode::DIRECTORY_TYPE)

      expect(duplicate).not_to be_valid
    end

    it 'validates parent is directory' do
      file_parent = create(:file_node, name: 'file.txt', parent: root_directory)
      child = build(:directory, name: 'child', parent: file_parent)

      expect(child).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'sets path automatically' do
      node = create(:directory, name: 'home')
      expect(node.path).to eq('/home')
    end

    it 'sets path with parent' do
      child = create(:directory, name: 'child', parent: root_directory)
      expect(child.path).to eq('/root/child')
    end
  end

  describe 'type methods' do
    it 'identifies directory correctly' do
      expect(root_directory).to be_directory
      expect(root_directory).not_to be_file
    end

    it 'identifies file correctly' do
      expect(file_node).to be_file
      expect(file_node).not_to be_directory
    end
  end

  describe 'navigation methods' do
    it 'identifies root node' do
      expect(root_directory).to be_root
      expect(subdirectory).not_to be_root
    end

    it 'calculates depth correctly' do
      expect(root_directory.depth).to eq(0)
      expect(subdirectory.depth).to eq(1)
      expect(file_node.depth).to eq(2)
    end
  end

  describe 'scopes' do
    before do
      root_directory
      subdirectory
      file_node
    end

    it 'filters directories' do
      directories = described_class.directories

      expect(directories).to include(root_directory)
      expect(directories).to include(subdirectory)
      expect(directories).not_to include(file_node)
    end

    it 'filters files' do
      files = described_class.files

      expect(files).to include(file_node)
      expect(files).not_to include(root_directory)
    end
  end
end
