# frozen_string_literal: true

module SearchworksMcp
  # Current item-level availability for a catalog record.
  module Availability
    extend self

    MAX_ONLINE_SOURCES = 5
    # Records with more items than this (e.g. long-running serials with a bound volume per year) are not
    # looked up item-by-item; the response would be far too large to be useful to a language model.
    MAX_ITEMS = 50
    HOLDINGS_ONLY_STATUS = "Multi"
    STALE_STATUS_NOTE = "Current status could not be retrieved; statuses shown are from the last catalog update " \
                        "and may be out of date."

    def fetch(id:, controller: nil)
      document = SearchServices.catalog(controller).fetch(id)
      items = document.holdings.items.reject(&:suppressed?)
      return LargeHoldings.response(document, items) if items.size > MAX_ITEMS

      live_records = live_lookup_records(document)
      result = {
        id: document.id.to_s,
        url: Urls.catalog(document.id),
        live_status: !live_records.nil?,
        availability: availability_records(document, live_records),
        online_sources: online_sources(document)
      }

      ToolResult.success(availability_text(result), result)
    rescue Blacklight::Exceptions::RecordNotFound
      ToolResult.failure("No catalog record found for id #{id}.")
    rescue StandardError => e
      ToolResult.internal_error(e, public_message: "Availability information is temporarily unavailable.")
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

    def online_source_lines(sources)
      return [] if sources.empty?

      ["Online access:"] + sources.map do |source|
        access = source[:stanford_only] ? " (Stanford-only)" : ""
        "- #{source[:label]}: #{source[:url]}#{access}"
      end
    end

    private

    # @return [Array<Hash>, nil] real-time item records from the ILS, or nil if the lookup failed or
    #   the record has no ILS instance to look up (e.g. SDR-only records such as ty162zv7580)
    def live_lookup_records(document)
      return if document[:uuid_ssi].blank?

      LiveLookup.new(document[:uuid_ssi]).records.reject { |record| holdings_only?(record) }
    rescue StandardError => e
      SearchworksMcp.report_exception(e, context: { id: document.id })
      nil
    end

    # FOLIO's RTAC returns holdings-level entries, not items, for instances with holdings but no items
    # (commonly e-resources). Without a holdings statement their status is the placeholder "Multi",
    # which says nothing about availability, so they are omitted in favor of the online sources.
    # Example: in00001145948, an e-book whose only RTAC entry is a holding (d3f5af6c-...) with status "Multi".
    def holdings_only?(record)
      record.with_indifferent_access[:status] == HOLDINGS_ONLY_STATUS
    end

    # Falls back to the item status indexed in Solr when the real-time lookup is unavailable,
    # as the availability display in the web application does.
    def indexed_records(items)
      items.reject(&:suppressed?).map do |item|
        {
          item_id: item.live_lookup_item_id,
          due_date: nil,
          status: item.folio_status,
          is_available: item.folio_status == 'Available'
        }
      end
    end

    def availability_records(document, live_records)
      holdings = document.holdings
      items = holdings.items.index_by(&:live_lookup_item_id)
      locations = holding_locations(document, holdings)
      (live_records || indexed_records(holdings.items)).map do |record|
        record = record.symbolize_keys
        rtac = record if live_records
        record.delete(:is_requestable_status)
        item = items[record[:item_id]]
        record.merge!(locations[record[:item_id]] || {})
        request_url = record[:request_url] || item_request_url(document, item, rtac)
        record[:request_url] = request_url if request_url
        record[:is_requestable] = request_url.present?
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
              call_number: item.callnumber(default: nil),
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

    def availability_text(result)
      lines = if result[:availability].any?
                availability_lines(result) + (result[:live_status] ? [] : [STALE_STATUS_NOTE])
              elsif result[:online_sources].any?
                ["Catalog record #{result[:id]} has no physical items to check; it is available online."]
              else
                ["No item availability information found for catalog record #{result[:id]}."]
              end
      lines.concat(online_source_lines(result[:online_sources]))
      lines << "URL: #{result[:url]}"
      lines.join("\n")
    end

    def availability_lines(result)
      ["Availability for catalog record #{result[:id]}:"] + result[:availability].map do |record|
        record = record.with_indifferent_access
        item = [record[:item_id], record[:status]].compact_blank.join(": ")
        physical_location = [record[:library], record[:location]].compact_blank.uniq.join(", ")
        item += " — #{physical_location}" if physical_location.present?
        item += " — Call number: #{record[:call_number]}" if record[:call_number].present?
        item += " (due #{record[:due_date]})" if record[:due_date].present?
        item += " — Request: #{record[:request_url]}" if record[:request_url].present?
        "- #{item}"
      end
    end
  end
end
