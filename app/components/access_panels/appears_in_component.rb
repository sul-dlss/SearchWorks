# frozen_string_literal: true

module AccessPanels
  class AppearsInComponent < AccessPanels::Base
    def render?
      document.set_member? && document.parent_sets.present?
    end
  end
end
