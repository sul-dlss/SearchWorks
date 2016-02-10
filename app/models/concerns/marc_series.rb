##
# Mixin to add access to linked and unlinked series to the SolrDocument
module MarcSeries
  def linked_series
    @linked_series ||= LinkedSeries.new(self)
  end

  def unlinked_series
    @unlinked_series ||= UnlinkedSeries.new(self)
  end
end
