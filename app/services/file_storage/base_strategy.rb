module FileStorage
  class BaseStrategy
    attr_reader :file_content

    def initialize(file_content)
      @file_content = file_content
    end

    def read_content
      raise NotImplementedError, 'Subclasses must implement read_content'
    end

    def write_content(data)
      raise NotImplementedError, 'Subclasses must implement write_content'
    end
  end
end
