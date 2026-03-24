# frozen_string_literal: true

module AccessPanels
  class AccessConditionsComponent < AccessPanels::Base
    delegate :cocina_display, to: :document

    def field_map
      return [] unless document.cocina?

      @field_map ||= [
        cocina_display.use_and_reproduction_display_data,
        cocina_display.copyright_display_data,
        cocina_display.license_display_data
      ].compact_blank
    end

    def render?
      field_map.present?
    end
  end
end
