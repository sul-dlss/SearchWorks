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
    show_oclc_citation? || citations_from_mods.present?
  end

  # @return [Hash] A hash of all citations for the document
  #          in the form of { citation_style => [citation_text] }
  def citations
    all_citations.presence || NULL_CITATION
  end

  # @return [Hash] A hash of MODS citations for the document
  #          Used when assembling citations for multiple documents
  #          in the form of { citation_style => [citation_text] }
  def mods_citations
    citations_from_mods.presence || {}
  end

  private

  attr_reader :document

  delegate :oclc_number, to: :document

  def all_citations
    @all_citations ||= begin
      citation_hash = {}

      citation_hash.merge!(citations_from_mods) if citations_from_mods.present?
      citation_hash.merge!(citations_from_oclc) if citations_from_oclc.present?

      citation_hash
    end
  end

  def citations_from_oclc
    return unless show_oclc_citation?

    @citations_from_oclc ||= Citations::OclcCitation.new(oclc_numbers: oclc_number).citations_by_oclc_number.fetch(oclc_number, {})
  end

  def citations_from_mods
    return unless document.mods && document.mods.note.present?

    @citations_from_mods ||= Citations::ModsCitation.new(notes: document.mods.note).all_citations
  end

  def show_oclc_citation?
    Settings.oclc_discovery.citations.enabled && oclc_number.present?
  end
end
