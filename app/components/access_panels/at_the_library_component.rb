# frozen_string_literal: true

module AccessPanels
  class AtTheLibraryComponent < AccessPanels::Base
    # @return [Array<Holdings::Library>] the list of libraries with holdings for the item
    def libraries
      @document.holdings.libraries.select(&:present?)
    end

    def render?
      libraries.any?(&:present?)
    end
  end
end
