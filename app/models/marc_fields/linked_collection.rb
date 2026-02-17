# frozen_string_literal: true

##
# A class to handle linked collection titles field logic
class LinkedCollection < MarcField
  def to_partial_path
    'marc_fields/linked_collection'
  end

  def values
    collection_titles.map(&:values).flatten.map(&:strip)
  end

  def collection_titles
    document.fetch(:collection_struct, [])
            .reject { |collection| collection[:source] == 'SDR-PURL' }
            .map { |collection| collection.slice(:title, :vernacular).compact }
            .reject(&:empty?)
  end
end
