require 'ld4l/open_annotation_rdf'

# This is model code to represent the OpenAnnotation RDF Data Model (http://www.openannotation.org/spec/core/).
#
# This model uses Cornell's OpenAnnotation models at https://github.com/ld4l/open_annotation_rdf 
# which utilize ActiveTriples (https://github.com/ActiveTriples/ActiveTriples).
# ActiveTriples is an ActiveModel-like interface for RDF data.
# Note that there is *no local storage* of Tags -- data is actually stored
# in our Triannon server, which is backed by Fedora4.  The triple store in scope
# for this model is a simple in-memory RDF Repository;  this allows us to easily
# work with linked data as objects in this Rails context, but the actual data store
# is external.
class Tag < LD4L::OpenAnnotationRDF::Annotation
  # FIXME:  one repo per tag object, or one repo for all tag objects?
  ActiveTriples::Repositories.add_repository :tags, RDF::Repository.new
  configure :repository => :tags
  
  validates :motivatedBy, length: {minimum: 1}
  validates :hasTarget, length: {minimum: 1}
  
  # override for class_name declaration
  property :hasBody, :predicate => RDFVocabularies::OA.hasBody, :class_name => TagTextBody


  # Set up Tag based on passed params
  # @param Hash tag_params params from TagController
  def initialize(tag_params)
    super

    # TODO: it should be possible to have multiple motivations
    motivatedBy << RDF::URI.new(RDF::OpenAnnotation.to_uri.to_s + tag_params["motivatedBy"]) if tag_params["motivatedBy"]

    # TODO: target will autofill from SW as IRI from OCLC number, OCLC work number, Stanford purl page, etc.
    # TODO: it should be possible to have multiple targets
    if tag_params["hasTarget"] && !tag_params["hasTarget"]["id"].blank?
      hasTarget << RDF::URI.new(Constants::CONTACT_INFO[:website][:url] + "/view/" + tag_params["hasTarget"]["id"])
    end

    # TODO: it should be possible to have multiple bodies
    if tag_params["hasBody"] && !tag_params["hasBody"]["id"].blank?
      body = TagTextBody.new
      body.content = tag_params["hasBody"]["id"]
      body.format = "text/plain"
      hasBody << body
    end

    # TODO: annotatedBy - from WebAuth

    annotatedAt << DateTime.now
  end
  
  # WRITE_COMMENTS_FOR_THIS_METHOD
  def save
    puts anno_graph.to_ttl
#    puts anno_graph.to_jsonld
    p "TODO: Send anno_graph to Triannon here! (Tag.save)"
    true
  end
  
  # WRITE_COMMENTS_FOR_THIS_METHOD
  def self.all
    p "TODO:  retrieve appropriate tags from Triannon here (Tag.all)"
    []
  end
  
protected
  
  # @return [RDF::Graph] a graph containing all relevant statements for storing this
  # object as an OpenAnnotation (e.g. including triples for body nodes) 
  def anno_graph
    g = RDF::Graph.new
    self.each_statement { |stmt| 
      g << stmt
    } 
    # add body graphs to main graph when they have content
    self.hasBody.find_all { |body| body.content.size > 0 && body.content.first.size > 0 }.each { |body_w_chars|
      body_w_chars.each_statement { |stmt|
        g << stmt
      }
    }
    g
  end
  
end
