# frozen_string_literal: true

module AccessPanels
  # Render a contact email if one was provided for the item.
  # Usually present for self-deposit content in SDR.
  class ContactInfoComponent < AccessPanels::Base
    delegate :cocina_display, to: :document

    def render?
      cocina_display&.contact_email_display_data.present?
    end
  end
end
