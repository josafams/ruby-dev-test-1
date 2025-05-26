require 'rails_helper'

RSpec.describe FileContent, type: :model do
  let(:file_node) { create(:file_node, name: 'test.txt') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      content = build(:file_content, file_system_node: file_node)
      expect(content).to be_valid
    end

    it 'requires storage type' do
      content = build(:file_content, storage_type: nil)
      expect(content).not_to be_valid
    end

    it 'validates valid storage type' do
      content = build(:file_content, storage_type: 'invalid')
      expect(content).not_to be_valid
    end
  end

  describe 'storage types' do
    it 'identifies blob storage type' do
      content = create(:file_content, :blob_storage, file_system_node: file_node)
      expect(content).to be_blob_storage
    end

    it 'identifies S3 storage type' do
      content = create(:file_content, :s3_storage, file_system_node: file_node)
      expect(content).to be_s3_storage
    end

    it 'identifies disk storage type' do
      content = create(:file_content, :disk_storage, file_system_node: file_node)
      expect(content).to be_disk_storage
    end
  end

  describe 'content access' do
    it 'returns blob content' do
      data = 'Blob content'
      content = create(:file_content, :blob_storage, file_system_node: file_node, blob_data: data)

      expect(content.content).to eq(data)
    end

    it 'returns file content from disk' do
      file_path = "/tmp/test_content_#{SecureRandom.hex}.txt"
      data = 'Disk content'

      File.write(file_path, data)
      content = create(:file_content, :disk_storage, file_system_node: file_node, file_path: file_path)

      expect(content.content).to eq(data)

      FileUtils.rm_f(file_path)
    end
  end

  describe 'callbacks' do
    it 'calculates checksum automatically' do
      data = 'Test content'
      content = build(:file_content, blob_data: data, checksum: nil)
      content.valid?

      expect(content.checksum).to eq(Digest::SHA256.hexdigest(data))
    end
  end
end
