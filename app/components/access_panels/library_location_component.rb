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

    def show_all_link
      return if consolidate_items?

      count_location_items = location.items.length

      return if display_items.length == count_location_items

      link_to("Browse all #{pluralize(count_location_items, 'item')}", availability_modal_path(document, { library: library.code }), data: { blacklight_modal: "trigger" })
    end

    def display_items
      location.items.first(5)
    end
  end
end
