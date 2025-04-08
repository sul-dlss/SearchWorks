# frozen_string_literal: true

##
# A class to handle MARC 752 field logic
# https://www.loc.gov/marc/bibliographic/bd752.html
class HierarchicalPlaceName < MarcField
  private

  def tags
    %w[752]
  end
end
