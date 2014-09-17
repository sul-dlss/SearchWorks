class MarcEdition < SearchWorksMarc
  def initialize(marc_record)
    @marc_record = remove_fields(
      marc_record.fields.select do |f|
        f.tag == '250'
      end
    )
  end

  private

  def format_subfields fields
    fields.map do |field|
      field.map do |subfield|
        subfield.value if %w{a b}.include?(subfield.code)
      end.compact.join(' ')
    end
  end
  def label_by_indicator key
    "Edition"
  end
end
