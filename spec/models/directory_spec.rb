require 'rails_helper'

RSpec.describe Directory, type: :model do
  let(:root) { create(:directory, name: 'root') }
  let(:documents) { create(:directory, name: 'documents', parent: root) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      directory = build(:directory, name: 'projects')
      expect(directory).to be_valid
    end

    it 'sets node type automatically' do
      directory = build(:directory, name: 'auto_type')
      directory.valid?
      expect(directory.node_type).to eq(FileSystemNode::DIRECTORY_TYPE)
    end
  end

  describe 'child creation' do
    it 'creates subdirectory successfully' do
      subdirectory = root.create_subdirectory('projects')

      expect(subdirectory).to be_persisted
      expect(subdirectory.name).to eq('projects')
      expect(subdirectory).to be_directory
    end

    it 'uses FileCreationService when creating files' do
      service_instance = instance_double(FileCreationService)
      allow(FileCreationService).to receive(:new).and_return(service_instance)
      allow(service_instance).to receive(:call).and_return(build(:file_node, name: 'test.txt'))

      documents.create_file('test.txt', content: 'test content')

      expect(FileCreationService).to have_received(:new).with(
        documents,
        'test.txt',
        content: 'test content',
        storage_type: 'blob'
      )
      expect(service_instance).to have_received(:call)
    end
  end

  describe 'child search' do
    let!(:subdirectory) { root.create_subdirectory('projects') }
    let!(:file) { root.create_file('readme.txt') }

    it 'finds child by name' do
      expect(root.find_child('projects')).to eq(subdirectory)
      expect(root.find_child('readme.txt')).to eq(file)
    end

    it 'finds file by name' do
      expect(root.find_file('readme.txt')).to eq(file)
    end
  end

  describe '#find_by_path' do
    let!(:projects_node) { root.create_subdirectory('projects') }
    let!(:projects) { described_class.find(projects_node.id) }
    let!(:web) { projects.create_subdirectory('web') }

    it 'finds by simple path' do
      result = root.find_by_path('projects')
      expect(result.id).to eq(projects_node.id)
      expect(result.name).to eq('projects')
    end

    it 'finds by nested path' do
      result = root.find_by_path('projects/web')
      expect(result.id).to eq(web.id)
      expect(result.name).to eq('web')
    end
  end

  describe 'state checks' do
    it 'identifies empty directory' do
      empty_dir = create(:directory, name: 'empty')
      expect(empty_dir).to be_empty
    end
  end
end
