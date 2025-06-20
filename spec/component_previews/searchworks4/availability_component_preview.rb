# frozen_string_literal: true

module Searchworks4
  class AvailabilityComponentPreview < Lookbook::Preview
    layout 'lookbook'

    # @!group Variations
    def single_item
      document = SolrDocument.from_fixture("2279186.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    def multiple_items_one_location
      document = SolrDocument.from_fixture("5488000.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # def multiple_items_multiple_locations; end
  end
  # @!endgroup
end
