module AccessPanels
  class AtTheLibraryComponent < AccessPanels::Base
    def libraries
      @document.holdings.libraries.select(&:present?)
    end

    def render?
      libraries.any?(&:present?)
    end
  end
end
