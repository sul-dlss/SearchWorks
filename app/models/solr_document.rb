# frozen_string_literal: true

class SolrDocument
  FORMAT_KEY = 'format_hsim'

  include MarcLinks
  include DigitalCollection
  include Extent
  include CollectionMember
  include ModsData
  include StacksImages
  include SolrHoldings
  include SolrSet
  include MarcMetadata
  include IiifConcern
  include DorContentMetadata
  include CollectionTitles

  include Blacklight::Solr::Document
  include SchemaDotOrg
  include Blacklight::Ris::DocumentFields
  include RisMapping

  delegate :empty?, :blank?, to: :to_h
  delegate :managed_purls, to: :marc_links

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
  attribute :db_az_subject, :array, :db_az_subject
  attribute :last_updated, :time, :last_updated

  def document_formats
    format.presence || old_format.presence || []
  end

  def file_ids
    self[:img_info] || self[:file_id] || []
  end

  def book_ids
    isbn = add_prefix_to_elements(Array(self['isbn_display']), 'ISBN')
    oclc = add_prefix_to_elements(Array(self['oclc']), 'OCLC')
    lccn = add_prefix_to_elements(Array(self['lccn']), 'LCCN')

    { 'isbn' => isbn, 'oclc' => oclc, 'lccn' => lccn }
  end

  def add_prefix_to_elements(arr, prefix)
    arr.map do |i|
      "#{prefix}#{i.to_s.gsub(/\W/, '')}"
    end
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

  def course_reserves
    @course_reserves ||= course_ids.present? ? Array(CourseReserve.find(*course_ids)).sort_by(&:course_number) : []
  end

  def is_a_database? # rubocop:disable Naming/PredicatePrefix
    document_formats.include? "Database"
  end

  def authors_from_index
    [self[:author_person_full_display], self[:vern_author_person_full_display],
     self[:author_corp_display], self[:vern_author_corp_display],
     self[:author_meeting_display], self[:vern_author_meeting_display]].flatten.compact.uniq
  end

  def druid
    self[:druid] || managed_purls.map(&:druid)&.first
  end

  def bookplates
    @bookplates ||= self[:bookplates_display]&.map do |bookplate_field|
      Bookplate.new(bookplate_field)
    end

    @bookplates ||= []
  end

  delegate :citable?, :citations, :mods_citations, :to_citeproc, to: :citation_object

  private

  def citation_object
    @citation_object ||= Citation.new(self)
  end
end
