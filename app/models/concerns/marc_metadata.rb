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
end
