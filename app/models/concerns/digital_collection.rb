module DigitalCollection
  def is_a_collection?
    self[:collection_type] and self[:collection_type].include?('Digital Collection')
  end

  def collection_members(options = {})
    return nil unless is_a_collection?

    @collection_members ||= CollectionMembers.new(self, options)
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
          fq: "collection:\"#{@document[:id]}\"",
          rows: 20
        }
      )['response']
    end

    def should_display_filmstrip?
      return unless number_of_documents_with_image_urls > 0

      number_of_documents_with_image_urls >= number_of_documents_without_image_urls
    end

    def number_of_documents_with_image_urls
      documents.count do |doc|
        doc.image_urls.present?
      end
    end

    def number_of_documents_without_image_urls
      documents.count do |doc|
        doc.image_urls.blank?
      end
    end

    def blacklight_solr
      Blacklight.default_index.connection
    end
  end
end
