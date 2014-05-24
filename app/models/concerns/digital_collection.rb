module DigitalCollection
  def is_a_collection?
    self[:collection_type] and self[:collection_type].include?('Digital Collection')
  end
end
