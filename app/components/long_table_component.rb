# frozen_string_literal: true

class LongTableComponent < ViewComponent::Base
  def initialize(node_id:, size:)
    @node_id = node_id
    @size = size
    super()
  end
  attr_reader :node_id, :size

  def truncate?
    size > 5
  end
end
