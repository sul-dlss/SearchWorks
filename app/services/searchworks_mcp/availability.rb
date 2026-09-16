# frozen_string_literal: true

module SearchworksMcp
  # Current item-level availability for a catalog record.
  module Availability
    extend self

    def fetch(id:, controller: nil)
      document = search_service(controller).fetch(id)
      records = LiveLookup.new(document[:uuid_ssi]).records
      result = {
        id: document.id.to_s,
        url: "https://searchworks.stanford.edu/view/#{ERB::Util.url_encode(document.id.to_s)}",
        availability: records
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

    def availability_text(result)
      return "No item availability information found for catalog record #{result[:id]}." if result[:availability].empty?

      lines = ["Availability for catalog record #{result[:id]}:"]
      result[:availability].each do |record|
        record = record.with_indifferent_access
        item = [record[:item_id], record[:status]].compact_blank.join(": ")
        item += " (due #{record[:due_date]})" if record[:due_date].present?
        lines << "- #{item}"
      end
      lines << "URL: #{result[:url]}"
      lines.join("\n")
    end
  end
end
