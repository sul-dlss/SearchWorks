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

    def location_request_link
      @location_request_link ||= LocationRequestLinkComponent.for(document:, library_code: library.code, location:)
    end

    private

    def consolidate_items?
      document.has_finding_aid? && policy.aeon_pageable?
    end

    def policy
      @policy ||= LocationRequestLinkPolicy.new(location:, library_code: library.code)
    end
  end
end
