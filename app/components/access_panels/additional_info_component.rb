# frozen_string_literal: true

module AccessPanels
  class AdditionalInfoComponent < ViewComponent::Base
    attr_reader :library, :document

    def initialize(library:, document:)
      @library = library
      @document = document
      super
    end
  end
end
