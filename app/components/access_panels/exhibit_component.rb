# frozen_string_literal: true

module AccessPanels
  class ExhibitComponent < AccessPanels::Base
    def render?
      Settings.EXHIBITS_ACCESS_PANEL.enabled && @document.druid
    end
  end
end
