# frozen_string_literal: true

module Record
  class ModsDocumentComponent < Blacklight::DocumentComponent
    delegate :mods_record_field, :mods_name_field, :linked_mods_subjects, :linked_mods_genres, to: :helpers

    attr_reader :layout

    def initialize(layout: Record::DocumentLayoutComponent, **)
      super

      @layout = layout
    end
  end
end
