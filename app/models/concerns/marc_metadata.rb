##
# A mixin to include MarcField subclasses into the SolrDocument
module MarcMetadata
  def language
    @language ||= Language.new(self)
  end

  def linked_author(target)
    @linked_author = {} if @linked_author.blank?
    @linked_author[target] ||= LinkedAuthor.new(self, target)
  end

  def physical_medium
    @physical_medium ||= PhysicalMedium.new(self)
  end

  def place_name
    @place_name ||= PlaceName.new(self)
  end
end
