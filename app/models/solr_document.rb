# frozen_string_literal: true

class SolrDocument
  FORMAT_KEY = 'format_hsim'

  include DocumentLinks
  include DisplayType
  include CourseReserves
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
  include MarcSubjects
  include IiifConcern
  include DorContentMetadata
  include CollectionTitles

  include Blacklight::Solr::Document
  include SchemaDotOrg
  include Blacklight::Ris::DocumentFields
  include RisMapping

  delegate :empty?, :blank?, to: :to_h
  delegate :managed_purls, to: :marc_links

  # TODO: change this to #to_param when we have upgraded to Blacklight 6.11.1
  def id
    (super || '').to_s.gsub('/', '%2F')
  end

  def eds_ris_export?
    false
  end

  def eds?
    false
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

  use_extension(Blacklight::Ris::DocumentExport) do |_|
    ris_field_mappings.merge!(
      RisMapping.field_mapping
    )
  end

  use_extension(FolioJsonExport) do |document|
    document.key?(:folio_json_struct)
  end

  use_extension(ModsExport) do |document|
    document.key?(:modsxml)
  end

  sw_field_semantics = {
    title: %w[title_display],
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

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  use_extension(Searchworks::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  attribute :course_ids, :array, :courses_folio_id_ssim
  attribute :format, :array, FORMAT_KEY
  attribute :old_format, :array, 'format_main_ssim'
  attribute :live_lookup_id, :string, 'uuid_ssi'
  attribute :oclc_number, :string, 'oclc'
  attribute :imprint_string, :string, :imprint_display
  attribute :vernacular_title, :string, :vern_title_display

  def document_formats
    format.presence || old_format.presence || []
  end

  def db_az_subject
    self[:db_az_subject] if is_a_database?
  end

  def file_ids
    self[:img_info] || self[:file_id] || []
  end

  # Checks holdings to see if there are any physical holdings
  # If there aren't and the library isn't sul, return the library name
  def eresources_library_display_name
    return if has_physical_copies?

    library_code = first(:holdings_library_code_ssim)

    return if library_code == 'SUL' || holdings&.libraries&.first&.code == 'SUL'

    ((Folio::Library.find_by(code: library_code) if library_code) || holdings&.libraries&.first)&.name
  end

  def has_physical_copies?
    holdings&.libraries&.any?(&:present?)
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

  # For use in the in the Lookbook component previews, `with_json` is false
  def self.from_fixture(filename, with_json: false)
    solr_data = SolrFixtureLoader.load(filename, with_json: with_json)
    new(solr_data)
  end
end
