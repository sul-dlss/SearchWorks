# frozen_string_literal: true

module Searchworks4
  class AvailabilityModalLocationComponent < AccessPanels::LibraryLocationComponent
    def display_items
      location.items
    end

    def volumes_display?
      location.code == 'SAL3-SEE-OTHER'
    end

    def volumes_display_classes
      'item-row w-100 flex-wrap fs-15 align-items-center'
    end
  end
end
