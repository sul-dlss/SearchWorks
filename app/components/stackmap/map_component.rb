# frozen_string_literal: true

module Stackmap
  class MapComponent < ViewComponent::Base
    def initialize(item:, stackmap_api_url:)
      @item = item
      @stackmap_api_url = stackmap_api_url
      super
    end

    attr_reader :item

    def api_url
      url = URI(@stackmap_api_url)
      url.query = {
        callno: item.callnumber,
        library: item.library,
        location: item.effective_permanent_location_code
      }.to_query
      url.to_s
    end
  end
end
