##
# A mixin to include MarcField subclasses into the SolrDocument
module MarcMetadata
  def language
    @language ||= Language.new(self)
  end
end
