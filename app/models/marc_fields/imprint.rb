class Imprint < MarcField
  private

  def preprocessors
    super + [:reject_non_imprint_subfields]
  end

  def reject_non_imprint_subfields
    relevant_fields.each do |field|
      field.subfields = field.subfields.reject do |subfield|
        !subfields.include?(subfield.code)
      end
    end
  end

  def tags
    %w(260)
  end

  def subfields
    %w(3 a b c e f g)
  end
end
