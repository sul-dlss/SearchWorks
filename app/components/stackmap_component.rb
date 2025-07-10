# frozen_string_literal: true

class StackmapComponent < ViewComponent::Base
  def initialize(items:, stackmap_api_url:)
    @items = items
    @stackmap_api_url = stackmap_api_url
    super
  end

  def api_url
    item = @items.first
    url = URI(@stackmap_api_url)
    url.query = {
      callno: item.callnumber,
      library: item.library,
      location: item.effective_permanent_location_code
    }.to_query
    url.to_s
  end
end
