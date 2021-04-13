class Imprint < MarcField
  def values
    extracted_fields.map do |_field, subfields|
      subfields.select { |subfield| %w(3 a b c e f g).include?(subfield.code) }.map(&:value).join(subfield_delimeter)
    end
  end

  private

  def tags
    %w(260)
  end
end
