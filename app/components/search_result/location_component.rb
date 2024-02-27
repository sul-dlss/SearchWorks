# frozen_string_literal: true

module SearchResult
  class LocationComponent < ViewComponent::Base
    def initialize(library:, document:)
      @library = library
      @document = document
      super()
    end

    attr_reader :library, :document

    delegate :code, to: :library, prefix: true

    def link_to_record
      link_to 'See full record for details', solr_document_path(document)
    end

    def bound_with?
      document.items.any?(&:bound_with?)
    end

    def locations
      library.locations.select(&:present_on_index?)
    end

    def display_request_link?
      !settings&.suppress_location_request_link
    end

    def show_items?
      !settings&.suppress_items_list_on_results_view
    end

    def settings
      Settings.libraries[library_code]
    end
  end
end
