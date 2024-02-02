module DigitalCollection
  def is_a_collection?
    self[:collection_type] and self[:collection_type].include?('Digital Collection')
  end

  def collection_members(options = {})
    return nil unless is_a_collection?

    @collection_members ||= CollectionMembers.new(self, options)
  end

  # @return [String] the matching collection id as stored in the :collection
  # field of collection member documents. This is important for linking
  # to a search for collection members because some store the collection catkey
  # prefixed with 'a' and others do not.
  def collection_id
    @collection_id ||= begin
      first_member = collection_members&.first || SolrDocument.new(collection: [])
      first_member[:collection].find do |col_member_col_id|
        CollectionHelper.strip_leading_a(col_member_col_id) == self[:id]
      end
    end
  end

  ###
  # Simple Plain Ruby Object to return an array of collection members
  class CollectionMembers
    delegate :[], :present?, :blank?, :each, :first, :last, :map, :length, to: :documents
    def initialize(document, options = {})
      @document = document
      @options = options
      @type = 'index'
    end

    def total
      response['numFound']
    end

    def documents
      @documents ||= response['docs'].map do |document|
        ::SolrDocument.new(document)
      end
    end

    def render_type
      @render_type ||= begin
        return 'list' unless should_display_filmstrip?

        'filmstrip'
      end
    end

    def with_type(type)
      @type = type
      self
    end

    def as_json(*)
      {
        total:,
        id: document[:id],
        html: render
      }
    end

    def to_partial_path
      'collection_members/show'
    end

    def render
      ApplicationController.render(
        template: to_partial_path,
        assigns: { document:, type: }
      )
    end

    private

    attr_reader :document, :options, :type

    def response
      @response ||= blacklight_solr.select(
        params: {
          fq: collection_member_params,
          rows: 20
        }
      )['response']
    end

    def should_display_filmstrip?
      return false if number_of_documents_with_image_urls.zero?

      number_of_documents_with_image_urls >= number_of_documents_without_image_urls
    end

    def number_of_documents_with_image_urls
      documents.count do |doc|
        doc.image_urls.present?
      end
    end

    # @return [Integer] a non-negative value
    def number_of_documents_without_image_urls
      documents.count do |doc|
        doc.image_urls.blank?
      end
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end

    # @return [String] a Solr query string
    # search for items with collection set to both prefixed and non-prefixed ids
    def collection_member_params
      [document[:id], document.prefixed_id].uniq.map do |collection_id|
        "collection:\"#{collection_id}\""
      end.join(" OR ")
    end
  end
end
