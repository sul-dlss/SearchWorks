# frozen_string_literal: true

module AccessPanels
  class GroupedLibraryComponent < ViewComponent::Base
    attr_reader :label, :libraries, :document

    # @params [Holdings::Library] library the holdings for the item at a particular library
    # @params [SolrDocument] document
    def initialize(label:, libraries:, document:)
      super

      @label = label
      @libraries = libraries
      @document = document
    end

    def render?
      libraries.any?
    end
  end
end
