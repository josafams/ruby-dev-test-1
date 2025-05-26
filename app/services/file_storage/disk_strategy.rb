module FileStorage
  class DiskStrategy < BaseStrategy
    def read_content
      return nil unless file_content.file_path && ::File.exist?(file_content.file_path)

      ::File.read(file_content.file_path)
    end

    def write_content(data)
      return unless data && file_content.file_path

      FileUtils.mkdir_p(::File.dirname(file_content.file_path))
      ::File.write(file_content.file_path, data)

      file_content.content_size = data.bytesize
      file_content.checksum = Digest::SHA256.hexdigest(data)
    end
  end
end
