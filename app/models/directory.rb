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

  # Sei que não é melhor maneira mas so pra jogar o básico que é adiciona paginação e um cache
  def list_contents(recursive: false, page: 1, per_page: 25)
    cache_key = cache_key_for('list_contents', recursive, page, per_page)

    with_cache(cache_key, expires_in: 5.minutes) do
      logger.debug "Listing contents for directory #{id}, recursive: #{recursive}, page: #{page}"

      if recursive
        descendants.with_content.paginated(page, per_page)
      else
        children.with_content.order(:node_type, :name).paginated(page, per_page)
      end
    end
  end

  def files_count(recursive: false)
    cache_key = cache_key_for('files_count', recursive)

    with_cache(cache_key, expires_in: 10.minutes) do
      logger.debug "Counting files for directory #{id}, recursive: #{recursive}"

      if recursive
        descendants.files.count
      else
        children.files.count
      end
    end
  end

  def directories_count(recursive: false)
    cache_key = cache_key_for('directories_count', recursive)

    with_cache(cache_key, expires_in: 10.minutes) do
      logger.debug "Counting directories for directory #{id}, recursive: #{recursive}"

      if recursive
        descendants.directories.count
      else
        children.directories.count
      end
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
