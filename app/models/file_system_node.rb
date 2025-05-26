class FileSystemNode < ApplicationRecord
  #  Classe base (Single Table Inheritance)

  DIRECTORY_TYPE = 'directory'.freeze
  FILE_TYPE = 'file'.freeze

  belongs_to :parent, class_name: 'FileSystemNode', optional: true
  has_many :children, class_name: 'FileSystemNode', foreign_key: 'parent_id', dependent: :destroy, inverse_of: :parent
  has_one :file_content, dependent: :destroy

  validates :name, presence: true
  validates :path, presence: true, uniqueness: true
  validates :node_type, presence: true, inclusion: { in: [DIRECTORY_TYPE, FILE_TYPE] }
  validates :name, uniqueness: { scope: :parent_id }
  validate :validate_parent_is_directory
  validate :validate_no_circular_reference

  # Normalmente sou CONTRA usar callbacks para validações, mas aqui é uma exceção devido o tempo de entrega hehehe.
  before_validation :set_path, if: :name_changed?
  before_save :calculate_size, if: :file?
  after_create :update_parent_size
  after_destroy :update_parent_size

  # Aqui posso montar uma DSL builder para criar os scopes.
  scope :directories, -> { where(node_type: DIRECTORY_TYPE) }
  scope :files, -> { where(node_type: FILE_TYPE) }
  scope :root_nodes, -> { where(parent_id: nil) }
  scope :in_directory, ->(directory) { where(parent: directory) }

  def directory?
    node_type == DIRECTORY_TYPE
  end

  def file?
    node_type == FILE_TYPE
  end

  def root?
    parent_id.nil?
  end

  def ancestors
    return [] if root?

    ancestors = []
    current = parent
    while current
      ancestors.unshift(current)
      current = current.parent
    end
    ancestors
  end

  def descendants
    return [] unless directory?

    descendants = []
    children.each do |child|
      descendants << child
      descendants.concat(child.descendants)
    end
    descendants
  end

  def siblings
    return FileSystemNode.none if root?

    parent.children.where.not(id: id)
  end

  def full_path
    return name if root?

    "#{ancestors.map(&:name).join('/')}/#{name}"
  end

  def depth
    ancestors.count
  end

  def calculate_total_size
    if file?
      file_content&.content_size || 0
    else
      children.sum(&:calculate_total_size)
    end
  end

  private

  def set_path
    self.path = if root?
                  "/#{name}"
                else
                  "#{parent.path}/#{name}"
                end
  end


  def validate_parent_is_directory
    return if parent.nil? || parent.directory?

    errors.add(:parent, 'deve ser um diretório')
  end

  def validate_no_circular_reference
    return if parent.nil?

    current = parent
    while current
      if current == self
        errors.add(:parent, 'não pode criar referência circular')
        break
      end
      current = current.parent
    end
  end

  def calculate_size
    self.size = file_content&.content_size || 0
  end

  def update_parent_size
    return unless parent

    parent.update!(size: parent.calculate_total_size)
    parent.send(:update_parent_size)
  end
end
