class FileContent < ApplicationRecord
  STORAGE_TYPES = %w[blob s3 disk].freeze

  belongs_to :file_system_node

  validates :storage_type, presence: true, inclusion: { in: STORAGE_TYPES }
  validates :content_size, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :checksum, presence: true
  validate :validate_storage_consistency

  before_validation :calculate_checksum, if: :blob_data_changed?
  before_validation :calculate_content_size, if: :blob_data_changed?

  scope :blob_storage, -> { where(storage_type: 'blob') }
  scope :s3_storage, -> { where(storage_type: 's3') }
  scope :disk_storage, -> { where(storage_type: 'disk') }
  scope :with_content, -> { where.not(blob_data: nil) }
  scope :without_content, -> { where(blob_data: nil) }

  def blob_storage?
    storage_type == 'blob'
  end

  def s3_storage?
    storage_type == 's3'
  end

  def disk_storage?
    storage_type == 'disk'
  end

  def blob_data?
    blob_data.present?
  end

  def s3_key?
    s3_key.present?
  end

  def file_path?
    file_path.present?
  end

  def content
    storage_strategy.read_content
  end

  def content=(data)
    storage_strategy.write_content(data)
  end

  def verify_checksum
    current_content = content
    return false unless current_content

    calculated_checksum = Digest::SHA256.hexdigest(current_content)
    calculated_checksum == checksum
  end

  def storage_location
    case storage_type
    when 'blob'
      'Banco de dados'
    when 's3'
      "S3: #{s3_key}"
    when 'disk'
      "Disco: #{file_path}"
    end
  end

  private

  def storage_strategy
    @storage_strategy ||= case storage_type
                          when 'blob'
                            FileStorage::BlobStrategy.new(self)
                          when 's3'
                            FileStorage::S3Strategy.new(self)
                          when 'disk'
                            FileStorage::DiskStrategy.new(self)
                          end
  end

  def validate_storage_consistency
    case storage_type
    when 'blob'
      errors.add(:s3_key, 'must be empty for blob storage') if s3_key.present?
      errors.add(:file_path, 'must be empty for blob storage') if file_path.present?
    when 's3'
      errors.add(:s3_key, 'is required for S3 storage') if s3_key.blank?
      errors.add(:blob_data, 'must be empty for S3 storage') if blob_data.present?
      errors.add(:file_path, 'must be empty for S3 storage') if file_path.present?
    when 'disk'
      errors.add(:file_path, 'is required for disk storage') if file_path.blank?
      errors.add(:blob_data, 'must be empty for disk storage') if blob_data.present?
      errors.add(:s3_key, 'must be empty for disk storage') if s3_key.present?
    end
  end

  def calculate_checksum
    return unless blob_data

    self.checksum = Digest::SHA256.hexdigest(blob_data)
  end

  def calculate_content_size
    self.content_size = blob_data&.bytesize || 0
  end
end
