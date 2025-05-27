module FileStorage
  class BlobStrategy < BaseStrategy
    def read_content
      log_operation('Blob read') do
        logger.debug "Reading blob data, size: #{file_content.content_size} bytes"
        file_content.blob_data
      end
    end

    def write_content(data)
      log_operation('Blob write') do
        if data.nil?
          logger.debug 'Writing empty blob data'
          file_content.blob_data = nil
          file_content.content_size = 0
          file_content.checksum = Digest::SHA256.hexdigest('')
        else
          logger.debug "Writing blob data, size: #{data.bytesize} bytes"
          file_content.blob_data = data
          file_content.content_size = data.bytesize
          file_content.checksum = Digest::SHA256.hexdigest(data)
        end
      end
    end

    def delete_content
      log_operation('Blob delete') do
        logger.debug 'Deleting blob data'
        file_content.blob_data = nil
        file_content.content_size = 0
        true
      end
    end
  end
end
