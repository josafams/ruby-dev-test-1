module FileStorage
  class BaseStrategy
    include SemanticLogger::Loggable
    include Retryable

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

    def delete_content
      raise NotImplementedError, 'Subclasses must implement delete_content'
    end

    protected

    def log_operation(operation, &block)
      start_time = Time.current
      logger.info "Starting #{operation} for #{file_content.storage_type} storage"
      
      result = yield
      
      duration = Time.current - start_time
      logger.info "Completed #{operation} in #{duration.round(3)}s"
      
      result
    rescue StandardError => e
      duration = Time.current - start_time
      logger.error "Failed #{operation} after #{duration.round(3)}s: #{e.message}"
      raise e
    end
  end
end
