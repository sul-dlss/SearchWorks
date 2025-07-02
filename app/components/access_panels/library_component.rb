# frozen_string_literal: true

module AccessPanels
  class LibraryComponent < ViewComponent::Base
    with_collection_parameter :library

    attr_reader :library, :document

    # @params [Holdings::Library] library the holdings for the item at a particular library
    # @params [SolrDocument] document
    def initialize(library:, document:)
      @library = library
      @document = document
    end

    def link_to_library_about_page(&)
      link_to_if library.about_url, capture(&), library.about_url
    end
  end
end
