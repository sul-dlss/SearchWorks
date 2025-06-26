# frozen_string_literal: true

module Searchworks4
  class AvailabilityComponentPreview < Lookbook::Preview
    layout 'lookbook'

    # @!group Variations

    # @label Single item in Green stacks (1391872)
    def single_item_green_stacks
      document = SolrDocument.from_fixture("1391872.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Single item in SAL3 (or some other requestable location) (2279186)
    def single_item_sal3
      document = SolrDocument.from_fixture("2279186.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Multiple (but not too many) items in Green stacks (10678312)
    def multiple_items_green_stacks
      document = SolrDocument.from_fixture("10678312.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Multiple items from a requestable location (5488000)
    def multiple_items_requestable_location
      document = SolrDocument.from_fixture("5488000.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Multiple items spread across multiple libraries or locations (402381)
    def multiple_items_multiple_locations
      document = SolrDocument.from_fixture("402381.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label (too) many items to show the details here (13840972)
    def many_items
      document = SolrDocument.from_fixture("13840972.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Online-only item (in00000444367)
    def online_item
      document = SolrDocument.from_fixture("in00000444367.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Mixed physical and online item (10838998)
    def mixed_physical_and_online
      document = SolrDocument.from_fixture("10838998.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Various copies, some checked out (3402192)
    def multi_copy_some_checked_out
      document = SolrDocument.from_fixture("3402192.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Aeon pageable location and an item with a temporary location (14239755)
    def aeon_and_temp_location
      document = SolrDocument.from_fixture("14239755.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end

    # @label Serial with some temporary locations (342324)
    def serial_with_some_temporary_locations
      document = SolrDocument.from_fixture("342324.yml")

      render Searchworks4::AvailabilityComponent.new(document: document)
    end
  end
  # @!endgroup
end
