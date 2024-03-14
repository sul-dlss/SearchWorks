# frozen_string_literal: true

##
# Mixin to add access to collection titles to the SolrDocument
module CollectionTitles
  def collection_titles
    fetch(:collection_struct, []).reject { |collection| collection[:source] == 'SDR-PURL' }
                                 .map { |collection| collection.slice(:title, :vernacular).compact }
                                 .reject(&:empty?)
  end
end
