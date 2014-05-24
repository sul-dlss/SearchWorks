module CollectionMember
  def is_a_collection_member?
    self[:collection] and self[:collection] != ['sirsi']
  end
end
