require 'ld4l/open_annotation_rdf'

# a generic model for tag bodies that have ContentAsText, with the repository set
#
# This is model code to represent bodies from the OpenAnnotation RDF Data Model (http://www.openannotation.org/spec/core/).
#
# This model uses Cornell's OpenAnnotation models at https://github.com/ld4l/open_annotation_rdf 
# which utilize ActiveTriples (https://github.com/ActiveTriples/ActiveTriples).
# ActiveTriples is an ActiveModel-like interface for RDF data.
# Note that there is *no local storage* of TagTextBody -- data is actually stored
# in our Triannon server, which is backed by Fedora4.  The triple store in scope
# for this model is a simple in-memory RDF Repository;  this allows us to easily
# work with linked data as objects in this Rails context, but the actual data store
# is external.
class TagTextBody < LD4L::OpenAnnotationRDF::CommentBody
  # FIXME:  one repo per object, or one repo for all objects?
  ActiveTriples::Repositories.add_repository :tags, RDF::Repository.new
  configure :repository => :tags
end
