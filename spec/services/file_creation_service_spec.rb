require 'rails_helper'

RSpec.describe FileCreationService, type: :service do
  let(:directory) { create(:directory, name: 'test_dir') }
  let(:file_name) { 'test_file.txt' }
  let(:content) { 'Hello, World!' }

  describe '#call' do
    it 'creates a file without content' do
      service = described_class.new(directory, file_name)
      file = service.call

      expect(file).to be_persisted
      expect(file.name).to eq(file_name)
      expect(file.node_type).to eq(FileSystemNode::FILE_TYPE)
      expect(file.parent).to eq(directory)
      expect(file.file_content).to be_nil
    end

    it 'creates a file with content' do
      service = described_class.new(directory, file_name, content: content)
      file = service.call

      expect(file).to be_persisted
      expect(file.name).to eq(file_name)
      expect(file.file_content).to be_present
      expect(file.file_content.content).to eq(content)
      expect(file.size).to eq(content.bytesize)
    end

    it 'creates a file with custom storage' do
      service = described_class.new(directory, file_name, content: content, storage_type: 's3')
      file = service.call

      expect(file.file_content.storage_type).to eq('s3')
    end
  end
end
