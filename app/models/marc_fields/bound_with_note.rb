###
#  MarcBoundWith class to return 590 fields that have a $c
###
class BoundWithNote < MarcField
  def values
    relevant_fields.map do |field|
      field.each_with_object({}) do |subfield, hash|
        hash[:value] ||= ''
        hash[:value] << "#{subfield.value} " unless subfield.code == 'c'
        hash[:id] = subfield.value[/^(\d+)/] if subfield.code == 'c'
      end
    end.flatten
  end

  def to_partial_path
    'marc_fields/bound_with_note'
  end

  private

  def preprocessors
    super + [:select_if_c_present]
  end

  def select_if_c_present
    relevant_fields.select! do |field|
      field['c'].present?
    end
  end

  def tags
    %w(590)
  end
end
