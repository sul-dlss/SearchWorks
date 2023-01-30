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

    # encourage long lines to wrap at punctuation
    # Note: the default line break character is the zero-width space
    def inject_line_break_opportunities(text, line_break_character: '​')
      text.gsub(/([:,;.]+)/, "\\1#{line_break_character}")
    end
  end
end
