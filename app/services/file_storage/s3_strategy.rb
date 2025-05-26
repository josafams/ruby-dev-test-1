module FileStorage
  class S3Strategy < BaseStrategy
    def read_content
      # Simulação de leitura do S3
      return nil unless file_content.s3_key.present?
      
      "Conteúdo simulado do S3 para chave: #{file_content.s3_key}"
    end

    def write_content(data)
      # Simulação de upload para S3
      return false unless data.present?
      
      Rails.logger.info "Simulando upload para S3: #{file_content.s3_key}"
      Rails.logger.info "Tamanho do arquivo: #{data.bytesize} bytes"
      
      true
    end

    def delete_content
      return false unless file_content.s3_key.present?
      
      Rails.logger.info "Simulando exclusão do S3: #{file_content.s3_key}"
      true
    end

    def generate_presigned_url(expires_in: 3600)
      # Em produção, geraria uma URL real do S3
      return nil unless file_content.s3_key.present?
      
      "https://meu-bucket.s3.amazonaws.com/#{file_content.s3_key}?expires=#{expires_in}"
    end
  end
end
