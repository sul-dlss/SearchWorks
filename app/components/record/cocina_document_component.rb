# frozen_string_literal: true

module Record
  class CocinaDocumentComponent < Blacklight::DocumentComponent
    attr_reader :layout

    def initialize(document: nil, layout: Record::DocumentLayoutComponent, **)
      super(document:, **)

      @layout = layout
    end
  end
end
