# frozen_string_literal: true

module AccessPanels
  class LibraryLocationComponent < ViewComponent::Base
    with_collection_parameter :location

    attr_reader :location, :library, :document

    # @params [Holdings::Location] location the location with the holdings
    # @params [Holdings::Library] library the library with the holdings
    # @params [SolrDocument] document
    def initialize(location:, library:, document:)
      @location = location
      @library = library
      @document = document
    end

    private

    def consolidate_items?
      document.has_finding_aid? && policy.aeon_pageable?
    end

    def policy
      @policy ||= LocationRequestLinkPolicy.new(location:, library_code: library.code)
    end

    def location_count?
      return false if consolidate_items?

      count_location_items = location.items.length

      return false if display_items.length == count_location_items

      count_location_items
    end

    def display_items
      location.items.first(5)
    end
  end
end
