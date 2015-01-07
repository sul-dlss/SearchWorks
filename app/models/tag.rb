require 'ld4l/open_annotation_rdf'
class Tag < LD4L::OpenAnnotationRDF::Annotation
  # FIXME:  one repo per tag object, or one repo for all tag objects?
  ActiveTriples::Repositories.add_repository :tags, RDF::Repository.new
  configure :repository => :tags
  
  validates :motivatedBy, presence: true
  
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
=begin
    # add body graphs to main graph when they have content
    self.hasBody.find_all { |body| body.content.size > 0 && body.content.first.size > 0 }.each { |body_w_chars|
      body_w_chars.each { |stmt|
        self << stmt
      }
    }
    # at this point, hasBody  becomes empty from the above ... why???

#    self.reload  # will this work?
=end
    puts self.to_ttl
#    puts self.to_jsonld
    p "TODO: Send anno to Triannon here! (Tag.save)"
    true
  end
  
  # WRITE_COMMENTS_FOR_THIS_METHOD
  def self.all
    p "TODO:  retrieve appropriate tags from Triannon here (Tag.all)"
    []
  end
end
