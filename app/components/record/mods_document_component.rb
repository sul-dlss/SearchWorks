# frozen_string_literal: true

module Record
  class ModsDocumentComponent < Blacklight::DocumentComponent
    delegate :mods_record_field, :mods_name_field, :linked_mods_subjects, :linked_mods_genres, to: :helpers
  end
end
