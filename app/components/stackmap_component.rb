# frozen_string_literal: true

class StackmapComponent < ViewComponent::Base
  def initialize(items:, stackmap_api_url:)
    @items = items
    @stackmap_api_url = stackmap_api_url
    super
  end

  attr_reader :items, :stackmap_api_url

  def tab_id_for(item)
    "tab-#{item.id}"
  end

  def target_id_for(item)
    "target-#{item.id}"
  end
end
