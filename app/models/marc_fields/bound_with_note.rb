###
#  MarcBoundWith class to return 590 fields that have a $c
###
class BoundWithNote < MarcField
  def values
    extracted_fields.map do |_field, subfields|
      id = subfields.find { |subfield| subfield.code == 'c' }.value[/^(\d+)/]

      value = subfields.reject { |subfield| subfield.code == 'c' }.map(&:value).join(subfield_delimeter)

      { id: id, value: value }
    end
  end

  def to_partial_path
    'marc_fields/bound_with_note'
  end

  private

  def extracted_fields
    super.select { |field, _subfields| field['c'].present? }
  end

  def tags
    %w(590)
  end
end
