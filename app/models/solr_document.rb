# -*- encoding : utf-8 -*-
class SolrDocument

  include MarcLinks
  include IndexLinks
  include DisplayType
  include CourseReserves
  include AccessPanelsConcern
  include DatabaseDocument
  include DigitalCollection
  include MarcCharacteristics
  include Extent
  include Edition
  include CollectionMember
  include ModsData
  include IndexAuthors
  include MarcImprint
  include MarcSeries
  include Druid
  include StacksImages
  include DigitalImage
  include OpenSeadragon
  include SolrHoldings
  include SolrSet
  include MarcInstrumentation
  include MarcBoundWithNote
  include SolrBookplates
  include Citable
  include MarcLinkedSerials

  include Blacklight::Solr::Document

  def initialize(*args)
    super
    self[:marcfield] = (self[:marcxml] || self[:marcbib_xml])
  end

      # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marcfield
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marcxml  ) || document.key?( :marcbib_xml  )
  end

  field_semantics.merge!(
                         :title => "title_display",
                         :author => "author_display",
                         :language => "language_facet",
                         :format => "format"
                         )



  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)

  # This abstraction method may become useful while
  # we're between using the new and old format facet
  def format_key
    :format_main_ssim
  end

  def file_ids
    self[:img_info] || self[:file_id] || []
  end

  concerning :MarcOrganizationAndArrangmenet do
    def organization_and_arrangement
      @organization_and_arrangement ||= OrganizationAndArrangement.new(self)
    end
  end
end
