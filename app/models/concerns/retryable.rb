# frozen_string_literal: true

module Retryable
  extend ActiveSupport::Concern

  included do
    include SemanticLogger::Loggable
  end

  class_methods do
    def with_retry(max_attempts: 3, delay: 0.5, backoff: 2, rescue_class: StandardError, &block)
      attempt = 1
      begin
        yield
      rescue rescue_class => e
        if attempt < max_attempts
          logger.warn "Attempt #{attempt} failed: #{e.message}. Retrying in #{delay}s..."
          sleep(delay)
          delay *= backoff
          attempt += 1
          retry
        else
          logger.error "All #{max_attempts} attempts failed. Last error: #{e.message}"
          raise e
        end
      end
    end
  end

  def with_retry(max_attempts: 3, delay: 0.5, backoff: 2, rescue_class: StandardError, &block)
    self.class.with_retry(
      max_attempts: max_attempts,
      delay: delay,
      backoff: backoff,
      rescue_class: rescue_class,
      &block
    )
  end
end 