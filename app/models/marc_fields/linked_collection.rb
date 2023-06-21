##
# A class to handle MARC 795 field logic
class LinkedCollection < MarcField
  def to_partial_path
    'marc_fields/linked_collection'
  end

  private

  def tags
    %w[795ap]
  end
end
