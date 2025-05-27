module FileStorage
  class DiskStrategy < BaseStrategy
    class DiskError < StandardError; end
    class DiskIOError < DiskError; end

    def read_content
      return nil unless file_content.file_path && ::File.exist?(file_content.file_path)

      log_operation('Disk read') do
        with_retry(max_attempts: 3, delay: 0.1, rescue_class: DiskIOError) do
          logger.debug "Reading from disk: #{file_content.file_path}"
          ::File.read(file_content.file_path)
        end
      end
    rescue Errno::ENOENT, Errno::EACCES => e
      logger.error "Disk read error: #{e.message}"
      raise DiskIOError, "Failed to read file: #{e.message}"
    end

    def write_content(data)
      return unless data && file_content.file_path

      log_operation('Disk write') do
        with_retry(max_attempts: 3, delay: 0.1, rescue_class: DiskIOError) do
          logger.debug "Writing to disk: #{file_content.file_path}, size: #{data.bytesize} bytes"

          FileUtils.mkdir_p(::File.dirname(file_content.file_path))
          ::File.write(file_content.file_path, data)

          file_content.content_size = data.bytesize
          file_content.checksum = Digest::SHA256.hexdigest(data)
        end
      end
    rescue Errno::ENOSPC, Errno::EACCES => e
      logger.error "Disk write error: #{e.message}"
      raise DiskIOError, "Failed to write file: #{e.message}"
    end

    def delete_content
      return false unless file_content.file_path && ::File.exist?(file_content.file_path)

      log_operation('Disk delete') do
        with_retry(max_attempts: 3, delay: 0.1, rescue_class: DiskIOError) do
          logger.debug "Deleting from disk: #{file_content.file_path}"
          ::File.delete(file_content.file_path)
          true
        end
      end
    rescue Errno::ENOENT, Errno::EACCES => e
      logger.error "Disk delete error: #{e.message}"
      raise DiskIOError, "Failed to delete file: #{e.message}"
    end
  end
end
