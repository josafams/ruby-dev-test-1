# frozen_string_literal: true

class UpdateParentSizeJob < ApplicationJob
  include SemanticLogger::Loggable
  include Retryable

  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(node_id)
    logger.info "Starting size update for node #{node_id}"

    with_retry(max_attempts: 3, delay: 1, rescue_class: ActiveRecord::RecordNotFound) do
      node = FileSystemNode.find(node_id)

      logger.debug "Updating size for node #{node.id} (#{node.name})"
      new_size = node.calculate_total_size

      node.update!(size: new_size)

      # Continue recursivamente se necessário
      if node.parent && node.parent.children.count <= 100
        node.parent.send(:update_parent_size)
      elsif node.parent
        UpdateParentSizeJob.perform_later(node.parent.id)
      end

      logger.info "Size update completed for node #{node_id}. New size: #{new_size}"
    end
  rescue ActiveRecord::RecordNotFound => e
    logger.warn "Node #{node_id} not found: #{e.message}"
  rescue StandardError => e
    logger.error "Failed to update size for node #{node_id}: #{e.message}"
    raise e
  end
end
