require 'ld4l/open_annotation_rdf'

# This is model code to represent the OpenAnnotation RDF Data Model (http://www.openannotation.org/spec/core/).
#
# This model uses Cornell's OpenAnnotation models at https://github.com/ld4l/open_annotation_rdf 
# which utilize ActiveTriples (https://github.com/ActiveTriples/ActiveTriples).
# ActiveTriples is an ActiveModel-like interface for RDF data.
# Note that there is *no local storage* of Tags -- data is actually stored
# in our Triannon (https://github.com/sul-dlss/triannon) server, which is backed by Fedora4.  
# 
# The triple store in scope for *this* Tag model is a simple in-memory RDF Repository;  
# this allows us to easily work with linked data as objects in this Rails context, 
# while the actual data store is external.
class Tag < LD4L::OpenAnnotationRDF::Annotation
  
  # FIXME: this will allow blank nodes???
#  LD4L::OpenAnnotationRDF.configuration.unique_tags = false
  
  validates :motivatedBy, length: {minimum: 1}
  validates :hasTarget, length: {minimum: 1}
  
  attr_accessor :triannon_id

  # Class Methods ----------------------------------------------------------------
  
 
  # Instance Methods ----------------------------------------------------------------

  # If first param is a Hash, then assume it is params from TagController - 
  #  remove those params and use them. 
  # Otherwise, just pass params through superclass
  # @see ActiveTriples::Resource
  def initialize(*args, &block)
    tag_params = args.shift if args.first.is_a?(Hash)

    super(*args, &block)

    if tag_params

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
    
  end
  
  # send the Tag as an OpenAnnotation to the OA Storage
  def save
#    puts anno_graph.to_ttl
    @triannon_id = post_anno_graph_to_storage
    if @triannon_id
      true
    else
      false
    end
  end

protected
  
  # @return <RDF::Graph> a graph containing all relevant statements for storing this
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
  
  # send turtle RDF data to OpenAnnotation Storage as an HTTP Post request
  # @return <String> unique id of newly created anno, or nil if there was a problem
  def post_anno_graph_to_storage
    response = conn.post do |req|
      req.headers['Content-Type'] = 'application/x-turtle'
      req.body = anno_graph.to_ttl
    end
    if response.status == 201
      new_url = response.headers['Location'] ? response.headers['Location'] : response.headers['location']
      return Tag.triannon_id_from_triannon_url new_url
    end
    return nil
  end
  
  # given a url, return the unique portion of it as the triannon_id
  # @return <String> triannon id - the unique path at the end of the url
  def self.triannon_id_from_triannon_url url
    return url.split(Settings.OPEN_ANNOTATION_STORE_URL).last if url
  end
  
  # @param <RDF::Graph> an annotation as a Graph
  # @return <String> triannon id for the annotation (the unique path at the end of the url)
  def self.triannon_id_from_anno_graph anno_graph
    solutions = anno_graph.query self.anno_query
    if solutions && solutions.size == 1
      return triannon_id_from_triannon_url(solutions.first.s.to_s)
    end
    nil
  end
  
  # query for a subject with type of RDF::OpenAnnotation.Annotation
  def self.anno_query
    @anno_query ||= begin
      q = RDF::Query.new
      q << [:s, RDF.type, RDF::URI("http://www.w3.org/ns/oa#Annotation")]
    end
  end
  
  def self.conn
    Faraday.new Settings.OPEN_ANNOTATION_STORE_URL
  end

  def conn    
    @c ||= self.class.conn
  end
  
end
