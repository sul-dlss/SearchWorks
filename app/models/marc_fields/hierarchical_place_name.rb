# frozen_string_literal: true

##
# A class to handle MARC 752 field logic
# https://www.loc.gov/marc/bibliographic/bd752.html
class HierarchicalPlaceName < MarcField
  def display_value(field, subfields)
    return if subfields.blank?

    subfields.inject(+'') do |acc, subfield|
      acc << if acc.blank?
               ''
             elsif subfield.code == 'e'
               if acc.ends_with?(',')
                 ' '
               else
                 ', '
               end
             else
               subfield_delimiter
             end
      acc << sanitize_marc_value(subfield_value(field, subfield))
    end
  end

  private

  def tags
    %w[752]
  end
end
