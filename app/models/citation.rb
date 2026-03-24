# frozen_string_literal: true

###
# Citation is a simple class that takes a Hash like object (SolrDocument)
# and returns a hash of citations
class Citation
  NULL_CITATION = { 'NULL' => '<p>No citation available for this record</p>'.html_safe }.freeze

  # @param document [SolrDocument] A document to generate citations for
  def initialize(document)
    @document = document
  end

  # @return [Boolean] Whether or not the document is citable
  def citable?
    citations_from_cocina.present? || citations_from_marc.present?
  end

  # @return [Hash] A hash of all citations for the document
  #          in the form of { citation_style => [citation_text] }
  def citations
    all_citations.presence || NULL_CITATION
  end

  def citeproc_item
    @citeproc_item ||= CiteprocItemService.create(document)
  end

  private

  attr_reader :document

  def all_citations
    @all_citations ||= begin
      citation_hash = {}

      citation_hash.merge!(citations_from_cocina) if citations_from_cocina.present?
      citation_hash.merge!(citations_from_marc) if citations_from_marc.present?

      citation_hash
    end
  end

  def citations_from_cocina
    return unless document.cocina?

    @citations_from_cocina ||= Citations::CocinaCitation.new(cocina_display: document.cocina_display).all_citations
  end

  def citations_from_marc
    return unless Settings.citeproc_citations.enabled && document.respond_to?(:to_marc) && document.to_marc && citeproc_item

    @citations_from_marc ||= Citations::MarcCitation.new(citeproc_item:).all_citations
  end
end
