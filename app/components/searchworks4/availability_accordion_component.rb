# frozen_string_literal: true

module Searchworks4
  class AvailabilityAccordionComponent < ViewComponent::Base
    with_collection_parameter :library

    attr_reader :library, :document, :index

    def initialize(library:, document:, toggled_library:, library_iteration: nil)
      @library = library
      @index = library_iteration&.index
      @document = document
      @toggled_library = toggled_library
      super
    end

    def toggled_library?
      return true unless @toggled_library

      @toggled_library == library.code
    end
  end
end
