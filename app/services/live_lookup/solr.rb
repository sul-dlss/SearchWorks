# frozen_string_literal: true

# LiveLookup::Solr makes a request to Solr with a list of bib ids
# and returns a response suitable for updating item availability
# information displayed on index and show views.
# Intended for use when no ILS is available for live lookup.
class LiveLookup
  class Solr
    attr_reader :ids

    delegate :as_json, :to_json, to: :records

    def initialize(ids)
      @ids = ids
    end

    # @return [Array] each item's current availability information, translated for display
    def records
      @records ||= response.dig('response', 'docs').flat_map do |doc|
        doc.fetch('item_display_struct', []).map do |item|
          LiveLookup::Solr::Record.new(JSON.parse(item)).as_json
        end
      end
    end

    private

    def response
      @response ||= solr_connection.get('select', params: query_params)
    end

    def query_params
      { q: "uuid_ssi:(#{document_ids})",
        fl: 'id, item_display_struct',
        facet: false,
        rows: 100 }
    end

    def document_ids
      ids.join(' OR ')
    end

    def solr_connection
      @solr_connection ||= RSolr.connect(url: Blacklight.connection_config[:url],
                                         timeout: 10,
                                         open_timeout: 10)
    end

    class Record
      attr_reader :item

      def initialize(item)
        @item = item
      end

      def as_json
        {
          item_id:,
          due_date: nil, # No due date available in the Solr document
          status:,
          is_available: available?,
          is_requestable_status: requestable_status?
        }
      end

      private

      def item_id
        item['id']
      end

      def available?
        status == 'Available'
      end

      def status
        item['status']
      end

      def library_code
        item['library']
      end

      # Check to see if we can add a request button based on the status in folio
      # and predetermined list of status that can be recalled
      def requestable_status?
        Settings.folio_hold_recall_statuses.include?(status)
      end
    end
  end
end
