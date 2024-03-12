# frozen_string_literal: true

##
# A class to handle MARC 740 field logic
# https://www.loc.gov/marc/bibliographic/bd740.html
class AddedEntry < MarcField
  def label
    f = marc[tags.first]

    if f&.indicator2 == '2'
      'Included Work'
    else
      super
    end
  end

  private

  def tags
    %w[740]
  end
end
