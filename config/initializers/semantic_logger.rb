# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  SemanticLogger.default_level = :debug
  SemanticLogger.add_appender(io: $stdout, formatter: :color)
else
  SemanticLogger.default_level = :info
  SemanticLogger.add_appender(io: $stdout, formatter: :json)
end

# Configurar logs específicos para performance
SemanticLogger['FileSystem'].level = :debug
SemanticLogger['Performance'].level = :info
SemanticLogger['Storage'].level = :debug 