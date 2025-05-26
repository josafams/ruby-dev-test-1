class FileCreationService
  attr_reader :directory, :name, :content, :storage_type, :options

  def initialize(directory, name, content: nil, storage_type: 'blob', **options)
    @directory = directory
    @name = name
    @content = content
    @storage_type = storage_type
    @options = options
  end

  def call
    file = create_file_node
    create_file_content(file) if content
    file
  end

  private

  def create_file_node
    directory.children.create!(
      name: name,
      node_type: FileSystemNode::FILE_TYPE,
      description: options[:description],
    )
  end

  def create_file_content(file)
    content_attrs = base_content_attributes.merge(storage_specific_attributes)
    file.create_file_content!(content_attrs)
    file.update!(size: content_attrs[:content_size])
  end

  def base_content_attributes
    {
      content_type: options[:content_type] || detect_content_type,
      storage_type: storage_type,
      content_size: content.bytesize,
      checksum: Digest::SHA256.hexdigest(content),
    }
  end

  def storage_specific_attributes
    case storage_type
    when 'blob'
      { blob_data: content }
    when 's3'
      { s3_key: options[:s3_key] || "files/#{SecureRandom.uuid}/#{name}" }
    when 'disk'
      { file_path: options[:file_path] || "/tmp/files/#{SecureRandom.uuid}/#{name}" }
    end
  end

  # Isso aqui provalmente deveria ser um helper ou mesmo usar de uma gem like imagerick ou etc para guardar os metadados do arquivo
  def detect_content_type
    extension = ::File.extname(name).downcase

    case extension
    when '.txt'
      'text/plain'
    when '.html', '.htm'
      'text/html'
    when '.css'
      'text/css'
    when '.js'
      'application/javascript'
    when '.json'
      'application/json'
    when '.xml'
      'application/xml'
    when '.pdf'
      'application/pdf'
    when '.jpg', '.jpeg'
      'image/jpeg'
    when '.png'
      'image/png'
    when '.gif'
      'image/gif'
    when '.svg'
      'image/svg+xml'
    else
      'application/octet-stream'
    end
  end
end
