# frozen_string_literal: true

module Record
  class MarcDocumentComponent < Blacklight::DocumentComponent
    delegate :render_if_present, to: :helpers
  end
end
