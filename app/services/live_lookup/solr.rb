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
      { q: "id:(#{document_ids})",
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
          barcode: item_id,
          due_date: nil, # No due date available in the Solr document
          status:,
          current_location: current_location_code,
          is_available: available?
        }
      end

      private

      def item_id
        item['barcode']
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

      def home_location_code
        item['home_location']
      end

      def current_location_code
        @current_location_code ||= item['current_location']
      end

      def current_location
        @current_location ||= Holdings::Location.new(current_location_code)
      end

      def home_location
        @home_location ||= Holdings::Location.new(home_location_code)
      end
    end
  end
end
