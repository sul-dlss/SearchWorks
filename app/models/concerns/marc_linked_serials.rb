##
# Mixing to add linked serials to the Solr Document model
module MarcLinkedSerials
  def linked_serials
    @linked_serials ||= LinkedSerials.new(self)
  end
end
