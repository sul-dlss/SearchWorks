module AccessPanels
  class AtTheLibraryComponent < AccessPanels::Base
    # @return [Array<Holdings::Library>] the list of libraries with holdings for the item
    def libraries
      @document.legacy_holdings.libraries.select(&:present?)
    end

    def render?
      libraries.any?(&:present?)
    end
  end
end
