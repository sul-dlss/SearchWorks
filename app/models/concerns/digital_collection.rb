module DigitalCollection
  def is_a_collection?
    self[:collection_type] and self[:collection_type].include?('Digital Collection')
  end

  def collection_members(options={})
    return nil unless is_a_collection?
    @collection_members ||= CollectionMembers.new(self)
  end

  private

  class CollectionMembers
    def initialize(document, options={})
      @options = options
      @document = document
    end

    def total
      response['numFound']
    end
    def documents
      response['docs'].map do |document|
        ::SolrDocument.new(document)
      end
    end
    private
    def response
      @response ||= Blacklight.solr.select(
        params: {
          fq: "collection:\"#{@document[:id]}\"",
          rows: (@options[:rows] || 20)
        }
      )['response']
    end
  end

end
