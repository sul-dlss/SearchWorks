# frozen_string_literal: true

module AccessPanels
  class AccessConditionsComponent < AccessPanels::Base
    def render?
      document.mods&.accessCondition.present?
    end
  end
end
