require 'ld4l/open_annotation_rdf'

# This is model code to represent the OpenAnnotation RDF Data Model (http://www.openannotation.org/spec/core/).
#
# This model uses Cornell's OpenAnnotation models at https://github.com/ld4l/open_annotation_rdf
# which utilize ActiveTriples (https://github.com/ActiveTriples/ActiveTriples).
# ActiveTriples is an ActiveModel-like interface for RDF data.
# Note that there is *no local storage* of Annotations -- data is actually stored
# in our Triannon (https://github.com/sul-dlss/triannon) server, which is backed by Fedora4.
#
# The triple store in scope for *this* Annotation model is a simple in-memory RDF Repository;
#  (see config/initializers/rdf_repositories.rb)
# This allows us to easily work with linked data as objects in this Rails context,
# while the actual data store is external.
#
# This model exists so our anno objects can get from and send to Triannon, and
#  possibly for validations of annos before they are written to Triannon.  Otherwise, the specific
#  ActiveTriples models above would be more appropriate.
class Annotation < LD4L::OpenAnnotationRDF::Annotation

  # FIXME: this will allow blank nodes???
#  LD4L::OpenAnnotationRDF.configuration.unique_tags = false

  validates :motivatedBy, length: {minimum: 1}
  validates :hasTarget, length: {minimum: 1}

  attr_accessor :triannon_id

  # Class Methods ----------------------------------------------------------------
  # TODO: move all the class methods to a find_annotations model concern?

  # Get an Array of Annotation objects with the param as an object of hasTarget
  # @param [String] target_uri this is a target_url in Annotations we are seeking
  # @return [Array<LD4L::OpenAnnotationRDF::Annotation>] an array of specifically typed objects
  #  (e.g.  LD4L::OpenAnnotationRDF::TagAnnotation, LD4L::OpenAnnotationRDF::CommmentAnnotation)
  #  loaded from the RDF::Graph data stored by Triannon
  def self.find_by_target_uri(target_uri)
    result = []
    if target_uri
      jsonld_annos_for_target_uri(target_uri).each { |anno_as_jsonld|
        result << Annotation.model_from_graph(RDF::Graph.new.from_jsonld(anno_as_jsonld))
      }
    end
    result
  end

  # --- below this line sort of "protected" or "private" class methods
  # TODO: move all these class methods to a find_annotations model concern?

  # get the annotations with the SearchWorks record as a target from Open Annotation Solr
  # @param [String] target_uri this is a target_url in Annotations we are seeking
  # @return [Array<String>] an Array of annotations as Strings containing jsonld
  def self.jsonld_annos_for_target_uri(target_uri)
    annos_as_jsonld = []
    solr_params = {defType: 'lucene', q: "target_url:#{RSolr.solr_escape(target_uri)}"}

    # RSolr handles url escaping
    rsolr_resp = oa_rsolr_conn.get 'select', params: solr_params
    if rsolr_resp && rsolr_resp["response"] && rsolr_resp["response"]["docs"]
      rsolr_resp["response"]["docs"].each { |anno_solr_doc|
        annos_as_jsonld << anno_solr_doc["anno_jsonld"]
      }
    end
    annos_as_jsonld
  end

  # @param [RDF::Graph] an annotation as a Graph
  # @return [LD4L::OpenAnnotationRDF::Annotation] but specifically typed (e.g. TagAnnotation, CommentAnnotation ...)
  def self.model_from_graph(graph)
    if graph && graph.size > 0
      anno_uri = RDF::URI.new(anno_uri_from_graph(graph))
      # remove extraneous statements from older versions of this anno's graph
      # TODO: need to remove extraneous statements of children of anno too (e.g. targets, bodies, annotatedBy ...)
      rdf_repo = ActiveTriples::Repositories.repositories[Annotation.repository]
      rdf_repo << graph
      rdf_repo.query(subject: anno_uri).each { |stmt|
        if graph.query(stmt).count == 0
          rdf_repo.send(:delete_statement, stmt)
        end
      }
      # TODO: should we also set the xx.triannon_id, which doesn't exist on the active-triples model?
      anno_model = LD4L::OpenAnnotationRDF::Annotation.resume(anno_uri)
    end
  end

  # @param [RDF::Graph] an annotation as a Graph
  # @return [String] uri for the annotation
  def self.anno_uri_from_graph graph
    solutions = graph.query self.anno_query
    if solutions && solutions.size == 1
      return solutions.first.s.to_s
    end
    nil
  end

  # query for a subject with type of RDF::Vocab::OA.Annotation
  def self.anno_query
    @anno_query ||= begin
      q = RDF::Query.new
      q << [:s, RDF.type, RDF::URI("http://www.w3.org/ns/oa#Annotation")]
    end
  end

  def self.oa_rsolr_conn
    @@rsolr_client ||= RSolr.connect url: Settings.OPEN_ANNOTATION_SOLR_URL
  end

  # Instance Methods ----------------------------------------------------------------

  # If first param is a Hash, then assume it is params from AnnotationController -
  #  remove those params and use them.
  # Otherwise, just pass params through superclass
  # @see ActiveTriples::Resource
  def initialize(*args, &block)
    anno_params = args.shift if args.first.is_a?(Hash)

    super(*args, &block)

    if anno_params

      # TODO: it should be possible to have multiple motivations
      motivatedBy << RDF::URI.new(RDF::Vocab::OA.to_uri.to_s + anno_params["motivatedBy"]) if anno_params["motivatedBy"]

      # TODO: target will autofill from SW as IRI from OCLC number, OCLC work number, Stanford purl page, etc.
      # TODO: it should be possible to have multiple targets
      if anno_params["hasTarget"] && !anno_params["hasTarget"]["id"].blank?
        hasTarget << RDF::URI.new(Constants::CONTACT_INFO[:website][:url] + "/view/" + anno_params["hasTarget"]["id"])
      end

      # TODO: it should be possible to have multiple bodies
      if anno_params["hasBody"] && !anno_params["hasBody"]["id"].blank?
        # TODO: motivatedBy should allow for mulitple motivations
        if motivatedBy.first == RDF::Vocab::OA.commenting
          body = LD4L::OpenAnnotationRDF::CommentBody.new
          body.content = anno_params["hasBody"]["id"]
          body.format = "text/plain"
          hasBody << body
        elsif motivatedBy.first == RDF::Vocab::OA.tagging
          body = LD4L::OpenAnnotationRDF::TagBody.new
          body.tag = anno_params["hasBody"]["id"]
          hasBody << body
        end
      end

      # TODO: annotatedBy - from WebAuth

      annotatedAt << DateTime.now
    end

  end

  # send the Annotation as an OpenAnnotation to the OA Storage
  def save
    @triannon_id = post_graph_to_oa_storage
    if @triannon_id
      true
    else
      false
    end
  end

protected

  # @return [RDF::Graph] a graph containing all relevant statements for storing this
  # object as an OpenAnnotation (e.g. including triples for body nodes)
  def graph
    g = RDF::Graph.new
    self.each_statement { |stmt|
      g << stmt
    }
    # add body graphs to main graph when they have content
    comment_or_tag_bodies = []
    comment_or_tag_bodies << self.hasBody.find_all { |body|
      (body.respond_to?(:content) && body.content.size > 0 && body.content.first.size > 0) ||
        (body.respond_to?(:tag) && body.tag.size > 0 && body.tag.first.size > 0)
    }
    comment_or_tag_bodies.flatten.each { |body_w_chars|
      body_w_chars.each_statement { |stmt|
        g << stmt
      }
    }
    g
  end

  # send turtle RDF data to OpenAnnotation Storage as an HTTP Post request
  # @return [String] unique id of newly created anno, or nil if there was a problem
  def post_graph_to_oa_storage
    response = oa_storage_conn.post do |req|
      req.headers['Content-Type'] = 'application/x-turtle'
      req.headers['Accept'] = 'application/x-turtle'
      req.body = graph.to_ttl
    end
    if response.status == 201
      # see https://github.com/sul-dlss/triannon/issues/218 -- this hasn't been implemented yet in Triannon
      #new_url = response.headers['Location'] ? response.headers['Location'] : response.headers['location']
      new_url = Annotation.anno_uri_from_graph(RDF::Graph.new.from_ttl(response.body))
      return triannon_id_from_triannon_url new_url
    end
    return nil
  end

  # given a url, return the unique portion of it as the triannon_id
  # @return [String] triannon id - the unique path at the end of the url
  def triannon_id_from_triannon_url url
    return url.split(Settings.OPEN_ANNOTATION_STORE_URL).last if url
  end

  def oa_storage_conn
    @oa_storage_conn ||= Faraday.new Settings.OPEN_ANNOTATION_STORE_URL
  end

end
