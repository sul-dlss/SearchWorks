# frozen_string_literal: true

##
# A class to handle MARC 790 field logic
class LocalSubjects < MarcField
  def to_partial_path
    'marc_fields/link_to_search'
  end

  def url
    { action: 'index', search_field: 'search' }
  end

  private

  def tags
    %w[790]
  end
end
