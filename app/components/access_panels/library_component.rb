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

    def link_to_library_about_page(**)
      return library.name if library.about_url.blank?

      link_to library.about_url, ** do
        safe_join([
          library.name,
          tag.i(class: 'bi-arrow-up-right ms-1', aria: { hidden: true })
        ])
      end
    end
  end
end
