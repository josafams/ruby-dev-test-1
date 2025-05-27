# frozen_string_literal: true

# Isso aqui poderia ser reduzido para um trailblazer da vida!
module Cacheable
  extend ActiveSupport::Concern

  included do
    include SemanticLogger::Loggable
  end

  class_methods do
    def cache_key_for(method, *args)
      "#{name.underscore}:#{method}:#{args.map(&:to_s).join(':')}"
    end

    def with_cache(key, expires_in: 1.hour, &block)
      Rails.cache.fetch(key, expires_in: expires_in) do
        logger.debug "Cache miss for key: #{key}"
        yield
      end
    end
  end

  def cache_key_for(method, *args)
    "#{self.class.name.underscore}:#{id}:#{method}:#{args.map(&:to_s).join(':')}"
  end

  def with_cache(key, expires_in: 1.hour, &block)
    Rails.cache.fetch(key, expires_in: expires_in) do
      logger.debug "Cache miss for key: #{key}"
      yield
    end
  end

  def expire_cache(pattern = nil)
    if pattern
      cache_key = cache_key_for(pattern)
    else
      cache_key = "#{self.class.name.underscore}:#{id}:*"
    end
    
    logger.debug "Expiring cache for pattern: #{cache_key}"
    Rails.cache.delete_matched(cache_key)
  end
end 