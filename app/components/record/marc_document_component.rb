# frozen_string_literal: true

module Record
  class MarcDocumentComponent < Blacklight::DocumentComponent
    delegate :render_if_present, to: :helpers

    attr_reader :layout

    def initialize(layout: Record::DocumentLayoutComponent, **)
      super

      @layout = layout
    end
  end
end
