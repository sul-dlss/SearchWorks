# frozen_string_literal: true

##
# A class to handle linked collection titles field logic
class LinkedCollection < MarcField
  def to_partial_path
    'marc_fields/linked_collection'
  end

  def values
    document.collection_titles.map(&:values).flatten.map(&:strip)
  end
end
