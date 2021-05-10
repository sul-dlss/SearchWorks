##
# A class to handle MARC 586 field logic
# https://www.loc.gov/marc/bibliographic/bd586.html
class Awards < MarcField
  private

  def display_value(field, subfields)
    safe_join [super, Constants::SOURCES[field['1']]].compact, subfield_delimeter
  end

  def tags
    %w[586 986]
  end
end
