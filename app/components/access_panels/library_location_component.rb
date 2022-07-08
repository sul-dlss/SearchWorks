module AccessPanels
  class LibraryLocationComponent < ViewComponent::Base
    with_collection_parameter :location

    attr_reader :location, :library, :document

    def initialize(location:, library:, document:)
      @location = location
      @library = library
      @document = document
    end
  end
end
