module AccessPanels
  class AtTheLibraryComponent < AccessPanels::Base
    # @return [Array<LocationWithHoldings>] the list of libraries with holdings for the item
    def libraries
      @document.holdings_per_library
    end

    def render?
      libraries
    end
  end
end
