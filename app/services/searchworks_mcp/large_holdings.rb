# frozen_string_literal: true

module SearchworksMcp
  # Availability response for records with too many items to list individually (e.g. long-running
  # serials with a bound volume per year). It skips the real-time lookup and points the user at
  # the record page in SearchWorks, which can show and request individual volumes.
  module LargeHoldings
    extend self

    def response(document, items)
      result = {
        id: document.id.to_s,
        url: Urls.catalog(document.id),
        live_status: false,
        too_many_items: true,
        item_count: items.size,
        availability: [],
        locations: location_summary(document.holdings),
        online_sources: Availability.online_sources(document)
      }

      ToolResult.success(text(result), result)
    end

    private

    def location_summary(holdings)
      holdings.libraries.flat_map do |library|
        library.locations.filter_map do |location|
          count = location.items.count { |item| !item.suppressed? }
          next if count.zero?

          { library: library.name || library.code, location: location.name || location.code, item_count: count }
        end
      end
    end

    def text(result)
      lines = [
        "Catalog record #{result[:id]} has #{result[:item_count]} items (for example, individual volumes of a " \
        "serial), which is too many to list here. Direct the user to #{result[:url]} to check the availability " \
        "of a specific volume and request it."
      ]
      if result[:locations].any?
        lines << "Held at:"
        result[:locations].each do |location|
          lines << "- #{location[:library]}, #{location[:location]} (#{location[:item_count]} items)"
        end
      end
      lines.concat(Availability.online_source_lines(result[:online_sources]))
      lines.join("\n")
    end
  end
end
