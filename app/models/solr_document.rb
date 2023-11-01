# -*- encoding : utf-8 -*-

class SolrDocument
  EDS_RESTRICTED_PATTERN = /^This title is unavailable for guests, please login to see more information./
  UPDATED_EDS_RESTRICTED_TITLE = 'This title is not available for guests. Log in to see the title and access the article.'.freeze

  include DocumentLinks
  include DisplayType
  include CourseReserves
  include AccessPanelsConcern
  include DatabaseDocument
  include DigitalCollection
  include Extent
  include CollectionMember
  include ModsData
  include IndexAuthors
  include MarcImprint
  include Druid
  include StacksImages
  include DigitalImage
  include SolrHoldings
  include SolrSet
  include MarcBoundWithNote
  include SolrBookplates
  include Citable
  include MarcMetadata
  include EdsDocument
  include EdsSubjects
  include MarcSubjects
  include IiifConcern
  include DorContentMetadata
  include LiveLookupIds
  include CollectionTitles

  include Blacklight::Solr::Document
  include SchemaDotOrg
  include EdsExport

  delegate :empty?, :blank?, to: :to_h

  # TODO: change this to #to_param when we have upgraded to Blacklight 6.11.1
  def id
    (super || '').to_s.gsub('/', '%2F')
  end

  # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marcxml
  extension_parameters[:marc_format_type] = :marcxml

  use_extension(Blacklight::Marc::DocumentExtension) do |document|
    document.key?(:marcxml) || document.key?(:marc_json_struct)
  end

  use_extension(MarcJsonExtension) do |document|
    document.key?(:marc_json_struct)
  end

  use_extension(EdsExport) do |document|
    document.key?(:eds_citation_exports) && document['eds_citation_exports']&.any? { |e| e['id'] == 'RIS' }
  end

  use_extension(FolioJsonExport) do |document|
    document.key?(:folio_json_struct)
  end

  use_extension(ModsExport) do |document|
    document.key?(:modsxml)
  end

  use_extension(SelectedDatabase) do |document|
    Settings.selected_databases[document.id].present?
  end

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

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Searchworks::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Searchworks::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # This abstraction method may become useful while
  # we're between using the new and old format facet
  def format_key
    :format_main_ssim
  end

  def file_ids
    self[:img_info] || self[:file_id] || []
  end

  concerning :MarcOrganizationAndArrangement do
    def organization_and_arrangement
      @organization_and_arrangement ||= OrganizationAndArrangement.new(self)
    end
  end

  # @return [String] the document id, prefixed with an 'a' if it's a numeric catkey
  # after FOLIO migration, all ILS-derived ids should be prefixed with 'a'
  def prefixed_id
    self[:id].to_s.sub(/^(\d+)$/, 'a\1')
  end
end
