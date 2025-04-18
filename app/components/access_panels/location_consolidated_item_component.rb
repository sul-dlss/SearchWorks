# frozen_string_literal: true

module AccessPanels
  class LocationConsolidatedItemComponent < LocationItemComponent
    def callnumber
      item.truncated_callnumber
    end
  end
end
