# frozen_string_literal: true

class StackmapComponent < ViewComponent::Base
  def initialize(items:, stackmap_api_url:)
    @items = items
    @stackmap_api_url = stackmap_api_url
    super
  end

  attr_reader :items, :stackmap_api_url

  def grouped_by_truncated_callnumbers
    @grouped_by_truncated_callnumbers ||= items.group_by(&:truncated_callnumber)
  end

  def tab_id_for(truncated_callnumber)
    "tab-#{truncated_callnumber.gsub(/\s+/, '-')}"
  end

  def target_id_for(truncated_callnumber)
    "target-#{truncated_callnumber.gsub(/\s+/, '-')}"
  end
end
