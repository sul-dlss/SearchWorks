# frozen_string_literal: true

module SearchworksMcp
  # Current item-level availability for a catalog record.
  module Availability
    extend self

    MAX_ONLINE_SOURCES = 5

    def fetch(id:, controller: nil)
      document = search_service(controller).fetch(id)
      records = availability_records(document)
      result = {
        id: document.id.to_s,
        url: "https://searchworks.stanford.edu/view/#{ERB::Util.url_encode(document.id.to_s)}",
        availability: records,
        online_sources: online_sources(document)
      }

      { text: availability_text(result), structured_content: result }
    rescue StandardError => e
      SearchworksMcp.internal_tool_error(e, public_message: "Availability information is temporarily unavailable.")
    end

    private

    def search_service(controller)
      config = CatalogController.blacklight_config
      state = Blacklight::SearchState.new({}, config, controller)
      Blacklight::SearchService.new(config: config, search_state: state)
    end

    def availability_records(document)
      holdings = document.holdings
      items = holdings.items.index_by(&:live_lookup_item_id)
      locations = holding_locations(document, holdings)
      LiveLookup.new(document[:uuid_ssi]).records.map do |record|
        record = record.symbolize_keys
        record.delete(:is_requestable_status)
        item = items[record[:item_id]]
        record.merge!(locations[record[:item_id]] || {})
        record[:request_url] ||= item_request_url(document, item, record)
        record[:is_requestable] = record[:request_url].present?
        record
      end
    end

    def holding_locations(document, holdings)
      holdings.libraries.each_with_object({}) do |library, item_locations|
        library.locations.each do |location|
          request_url = location_request_url(document, library, location)
          location.items.each do |item|
            item_locations[item.live_lookup_item_id] = {
              library: library.name || library.code,
              library_code: library.code,
              location: location.name || location.code,
              location_code: location.code,
              request_url:
            }.compact
          end
        end
      end
    end

    def location_request_url(document, library, location)
      return unless LocationRequestLinkPolicy.new(location:, library_code: library.code).show?

      ApplicationController.helpers.request_url(document, library: library.code, location: location.code)
    end

    def item_request_url(document, item, rtac)
      return unless item && ItemRequestLinkPolicy.new(item:, rtac:).show?

      ApplicationController.helpers.request_url(
        document,
        library: item.library,
        location: item.effective_permanent_location_code,
        barcode: item.barcode
      )
    end

    def online_sources(document)
      document.preferred_online_links.first(MAX_ONLINE_SOURCES).filter_map do |link|
        next if link.href.blank?

        {
          url: link.href,
          label: link.link_text,
          stanford_only: !!link.stanford_only?
        }
      end
    end

    def availability_text(result)
      lines = if result[:availability].empty?
                ["No item availability information found for catalog record #{result[:id]}."]
              else
                availability_lines(result)
              end
      if result[:online_sources].any?
        lines << "Online access:"
        result[:online_sources].each do |source|
          access = source[:stanford_only] ? " (Stanford-only)" : ""
          lines << "- #{source[:label]}: #{source[:url]}#{access}"
        end
      end
      lines << "URL: #{result[:url]}"
      lines.join("\n")
    end

    def availability_lines(result)
      ["Availability for catalog record #{result[:id]}:"] + result[:availability].map do |record|
        record = record.with_indifferent_access
        item = [record[:item_id], record[:status]].compact_blank.join(": ")
        physical_location = [record[:library], record[:location]].compact_blank.uniq.join(", ")
        item += " — #{physical_location}" if physical_location.present?
        item += " (due #{record[:due_date]})" if record[:due_date].present?
        item += " — Request: #{record[:request_url]}" if record[:request_url].present?
        "- #{item}"
      end
    end
  end
end
