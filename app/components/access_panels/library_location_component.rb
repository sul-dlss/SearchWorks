module AccessPanels
  class LibraryLocationComponent < ViewComponent::Base
    with_collection_parameter :location

    attr_reader :location, :library, :document

    def initialize(location:, library:, document:)
      @location = location
      @library = library
      @document = document
    end

    def location_request_link
      @location_request_link ||= LocationRequestLinkComponent.for(document: document, library: library.code, location: location.code, items: location.items)
    end
  end
end
