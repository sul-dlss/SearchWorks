# frozen_string_literal: true

##
# A class to parse MARC 752 Hierarchical Place Name for display
# https://www.loc.gov/marc/bibliographic/bd752.html
# Appears as 'Location' in bibliographic information
class PlaceName < MarcField
  private

  def subfield_delimeter
    ' -- '
  end

  def tags
    %w(752)
  end
end
