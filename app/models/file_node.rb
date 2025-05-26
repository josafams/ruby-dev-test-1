class FileNode < FileSystemNode
  before_validation :set_node_type

  validates :node_type, inclusion: { in: [FILE_TYPE] }

  delegate :content_type, :storage_type, :content_size, :checksum, :content, to: :file_content, allow_nil: true

  def extension
    ::File.extname(name).downcase
  end

  def basename
    ::File.basename(name, extension)
  end

  private

  def set_node_type
    self.node_type = FILE_TYPE
  end
end
