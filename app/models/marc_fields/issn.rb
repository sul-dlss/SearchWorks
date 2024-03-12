# frozen_string_literal: true

##
# A class to handle MARC 022a + 022z field logic
# https://www.loc.gov/marc/bibliographic/bd022.html
class Issn < MarcField
  def values
    return [] if marc.blank?

    @values ||= extracted_fields.flat_map do |field, subfields|
      subfields.map { |x| x.value.strip }.select { |v| v =~ issn_pattern }
    end.compact
  end

  private

  def tags
    %w[022az]
  end

  def issn_pattern
    /^\d{4}-\d{3}[X\d]\D*$/
  end
end
