##
# Mixin to add access to subjects to the SolrDocument
module MarcSubjects
  def subjects(tags)
    @subjects ||= {}
    @subjects[tags] ||= Subjects.new(self, tags)
  end
end
