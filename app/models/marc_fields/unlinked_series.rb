##
# A class to parse MARC Series fields that are not linked to series searches
# All alpha subfields are included in the text
class UnlinkedSeries < MarcField
  include SeriesLinkable

  private

  def preprocessors
    super + [:reject_linkable_series_fields]
  end

  def reject_linkable_series_fields
    relevant_fields.reject! { |field| series_is_linkable?(field) }
  end
end
