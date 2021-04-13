##
# MarcField class to parse MARC 351s. The MARC spec indicates that the only
# human readable subfields for this particular field are $3, $a, $b, and $c.
class OrganizationAndArrangement < MarcField
  def values
    extracted_fields.map do |_field, subfields|
      subfields.select { |subfield| %w(3 a b c).include?(subfield.code) }.map(&:value).join(subfield_delimeter)
    end
  end

  private

  def tags
    ['351']
  end
end
