# frozen_string_literal: true

module AccessPanels
  class ExhibitComponent < AccessPanels::Base
    def render?
      @document.druid
    end
  end
end
