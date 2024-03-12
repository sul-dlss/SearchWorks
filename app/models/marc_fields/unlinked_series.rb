# frozen_string_literal: true

##
# A class to parse MARC Series fields that are not linked to series searches
# All alpha subfields are included in the text
class UnlinkedSeries < MarcField
  include SeriesLinkable

  private

  def extracted_fields
    super.reject { |field, _subfields| series_is_linkable?(field) }
  end
end
