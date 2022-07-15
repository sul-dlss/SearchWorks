module AccessPanels
  class CdlComponent < AccessPanels::Base
    def render?
      @document.cdl?
    end
  end
end
