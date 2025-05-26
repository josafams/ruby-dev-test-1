class Directory < FileSystemNode
  before_validation :set_node_type

  validates :node_type, inclusion: { in: [DIRECTORY_TYPE] }

  def create_subdirectory(name, description: nil)
    children.create!(
      name: name,
      node_type: DIRECTORY_TYPE,
      description: description,
    )
  end

  def create_file(name, content: nil, storage_type: 'blob', **)
    FileCreationService.new(
      self,
      name,
      content: content,
      storage_type: storage_type,
      **,
    ).call
  end

  def find_child(name)
    children.find_by(name: name)
  end

  def find_file(name)
    children.files.find_by(name: name)
  end

  def find_directory(name)
    children.directories.find_by(name: name)
  end

  def find_by_path(relative_path)
    return self if relative_path.blank? || relative_path == '.'

    parts = relative_path.split('/').compact_blank
    current = self

    parts.each do |part|
      child = current.find_child(part)
      return nil unless child

      current = child.directory? ? child.becomes(Directory) : child
      return nil if parts.last != part && !current.is_a?(Directory)
    end

    current
  end

  def list_contents(recursive: false)
    if recursive
      descendants
    else
      children.order(:node_type, :name)
    end
  end

  def files_count(recursive: false)
    if recursive
      descendants.count(&:file?)
    else
      children.files.count
    end
  end

  def directories_count(recursive: false)
    if recursive
      descendants.count(&:directory?)
    else
      children.directories.count
    end
  end

  delegate :empty?, to: :children

  def has_files?
    children.files.exists?
  end

  def has_directories?
    children.directories.exists?
  end

  private

  def set_node_type
    self.node_type = DIRECTORY_TYPE
  end
end
