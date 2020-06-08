##
# MarcField class to parse MARC 351s. The MARC spec indicates that the only
# human readable subfields for this particular field are $3, $a, $b, and $c.
class OrganizationAndArrangement < MarcField
  private

  def preprocessors
    super + [:relevant_subfields]
  end

  def relevant_subfields
    relevant_fields.each do |field|
      field.subfields = field.subfields.select do |subfield|
        %w(3 a b c).include?(subfield.code)
      end
    end
  end

  def tags
    ['351']
  end
end
