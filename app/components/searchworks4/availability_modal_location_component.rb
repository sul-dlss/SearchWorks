# frozen_string_literal: true

module Searchworks4
  class AvailabilityModalLocationComponent < AccessPanels::LibraryLocationComponent
    def display_items
      location.items
    end
  end
end
