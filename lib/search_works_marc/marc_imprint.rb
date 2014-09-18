class MarcImprint < SearchWorksMarc

  private

  def selected_fields
    @fields.select! do |field|
      field.tag == '260'
    end
  end

  def format_subfields fields
    fields.map do |field|
      field.map do |subfield|
        subfield.value if %w{a b c e f g}.include?(subfield.code)
      end.compact.join(' ')
    end
  end
  def label_by_indicator key
    "Imprint"
  end
  def grouping
    @fields.group_by do |field|
      label_by_indicator(nil)
    end
  end
end
