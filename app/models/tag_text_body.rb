require 'ld4l/open_annotation_rdf'
# a generic model for tag bodies that have ContentAsText, with the repository set
class TagTextBody < LD4L::OpenAnnotationRDF::CommentBody
  # FIXME:  one repo per object, or one repo for all objects?
  ActiveTriples::Repositories.add_repository :tags, RDF::Repository.new
  configure :repository => :tags
end
