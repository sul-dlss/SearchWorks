# frozen_string_literal: true

module Record
  class MarcDocumentComponent < Blacklight::DocumentComponent
    delegate :render_if_present, to: :helpers

    attr_reader :layout

    def initialize(document: nil, layout: Record::DocumentLayoutComponent, **)
      super(document:, **)

      @layout = layout
    end
  end
end
