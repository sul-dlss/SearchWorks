# frozen_string_literal: true

##
# BoundWithNoteForAccessPanel class to return only those 590 fields that have a $c
#   for display in access panels, which differs slightly from the normal display.
class BoundWithNoteForAccessPanel < BoundWithNote
  def values
    extracted_fields.map do |field, subfields|
      id = subfields.find { |subfield| subfield.code == 'c' }.value[ckey_regex]

      { id:, value: display_value(field, subfields) }
    end
  end

  def to_partial_path
    'marc_fields/bound_with_note_for_access_panel'
  end

  private

  def extracted_fields
    super.select { |field, _subfields| field['c'].present? }
  end

  def display_value(field, subfields)
    safe_join subfields.reject { |subfield| subfield.code == 'c' }.map { |subfield| subfield_value(field, subfield) }, subfield_delimiter
  end
end
