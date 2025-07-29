# frozen_string_literal: true

module Searchworks4
  class AvailabilityAccordionComponent < ViewComponent::Base
    with_collection_parameter :library

    attr_reader :library, :document, :index

    def initialize(library:, document:, toggled_library:, libraries: nil, library_iteration: nil)
      @library = library
      @index = library_iteration&.index
      @document = document
      @toggled_library = toggled_library
      @libraries = libraries
      super
    end

    def render?
      library.present?
    end

    def item_count
      libraries.sum { |library| library.items.count }
    end

    # mostly used for easy grouping of SAL libraries
    def libraries
      @libraries.presence || [library]
    end

    def toggled_library?
      return true unless @toggled_library

      @toggled_library == library.code
    end
  end
end
