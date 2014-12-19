#class Tag < ActiveRecord::Base
require 'ld4l/open_annotation_rdf'
class Tag < LD4L::OpenAnnotationRDF::Annotation
  # FIXME:  one repo per tag object, or one repo for all tag objects?
  ActiveTriples::Repositories.add_repository :tags, RDF::Repository.new
  configure :repository => :tags
  
  validates :motivatedBy, presence: true
  
  # WRITE_COMMENTS_FOR_THIS_METHOD
  def save
    p "TODO: Send anno to Triannon here! (Tag.save)"
    puts self.to_ttl
  end
  
  # WRITE_COMMENTS_FOR_THIS_METHOD
  def self.all
    p "TODO:  retrieve appropriate tags from Triannon here (Tag.all)"
    []
  end
end
