# -*- encoding : utf-8 -*-
class SolrDocument

  include MarcLinks
  include IndexLinks
  include DisplayType
  include CourseReserves
  include LibraryLocations
  include AccessPanelsConcern
  include DatabaseDocument
  include DigitalCollection
  include CollectionMember
  include ModsData
  include IndexAuthors
  include Druid
  include DigitalImage
  include OpenSeadragon
  include SolrHoldings

  include Blacklight::Solr::Document
      # The following shows how to setup this blacklight document to display marc documents
  extension_parameters[:marc_source_field] = :marcxml
  extension_parameters[:marc_format_type] = :marcxml
  use_extension( Blacklight::Solr::Document::Marc) do |document|
    document.key?( :marcxml  )
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
    :format
  end

  def file_ids
    self[:img_info] || self[:file_id]
  end

end
