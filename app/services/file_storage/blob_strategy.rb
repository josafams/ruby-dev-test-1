module FileStorage
  class BlobStrategy < BaseStrategy
    def read_content
      file_content.blob_data
    end

    def write_content(data)
      if data.nil?
        file_content.blob_data = nil
        file_content.content_size = 0
        file_content.checksum = Digest::SHA256.hexdigest('')
      else
        file_content.blob_data = data
        file_content.content_size = data.bytesize
        file_content.checksum = Digest::SHA256.hexdigest(data)
      end
    end
  end
end
