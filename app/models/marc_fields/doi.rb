# frozen_string_literal: true

##
# A class to handle MARC 024 field logic
# https://www.loc.gov/marc/bibliographic/bd024.html
class Doi < MarcField
  def values
    return [] if marc.blank?

    @values ||= extracted_fields.select { |fields, _subfields| fields['2'] == 'doi' }.filter_map do |field, subfields|
      display_value(field, subfields)
    end
  end

  private

  def tags
    %w[024a]
  end
end
