# -*- encoding : utf-8 -*-
# frozen_string_literal: true

class EdsDocument
  EDS_RESTRICTED_PATTERN = /^This title is unavailable for guests, please login to see more information./

  include Blacklight::Solr::Document
  delegate :empty?, :blank?, to: :to_h

  include EdsLinks
  include EdsSubjects
  include EdsExport

  # self.unique_key = 'id'

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  use_extension(Searchworks::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  use_extension(EdsExport, &:eds_ris_export?)

  sw_field_semantics = {
    title: %w[title_display eds_title],
    author: 'author_display',
    language: 'language_facet',
    format: 'format'
  }

  ##
  # Use catalog_field_semantics by default
  field_semantics.merge!(sw_field_semantics)

  ##
  # Overriding method until we get a version of Blacklight with new functionality
  def to_semantic_values
    semantic_value_hash = super
    semantic_value_hash = self.class.field_semantics.each_with_object(semantic_value_hash) do |(key, field_names), hash|
      ##
      # Handles single string field_name or an array of field_names
      value = Array.wrap(field_names).map { |field_name| self[field_name] }.flatten.compact

      # Make single and multi-values all arrays, so clients
      # don't have to know.
      hash[key] = Array.wrap(value) unless value.empty?
    end

    semantic_value_hash || {}
  end

  # TODO: change this to #to_param when we have upgraded to Blacklight 6.11.1
  def id
    (super || '').to_s.gsub('/', '%2F')
  end

  def eds?
    true
  end

  def eds_ris_export?
    key?(:eds_citation_exports) && self['eds_citation_exports']&.any? { |e| e['id'] == 'RIS' }
  end

  def preferred_online_links
    eds_links&.fulltext || []
  end

  def html_fulltext?
    self['eds_html_fulltext_available'] == true
  end

  def research_starter?
    # TODO: we probably need a better way to determine this
    self['eds_database_name'] == 'Research Starters'
  end

  def eds_restricted?
    # TODO: we probably need a better way to determine this
    self['eds_title'] =~ ::EdsDocument::EDS_RESTRICTED_PATTERN
  end

  concerning :EdsCitations do
    def citable?
      eds_citations.present?
    end

    def citations
      eds_citations.presence || Citation::NULL_CITATION
    end

    def eds_citations
      return {} if self['eds_citation_styles'].blank?

      Citations::EdsCitation.new(eds_citations: self['eds_citation_styles']).all_citations.presence || {}
    end
  end

  # These stub methods are used by components shared with SolrDocument:
  def is_a_database? = false # rubocop:disable Naming/PredicateName
  def druid = nil
  def eresources_library_display_name = nil
  def mods = nil
  def oclc_number = nil

  def display_type = 'eds'

  def holdings
    Holdings.new([], [])
  end

  def marc_links
    Links.new([])
  end
end
