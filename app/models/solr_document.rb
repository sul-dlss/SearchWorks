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

  # Check for digital image object
  # TODO: Once index fields are finalized, remove additional check
  def is_a_digital_image?
    self[:display_type].first == 'image' and (self.has_key?("img_info") or self.has_key?("file_id"))
  end


  # Get stacks urls for a document using file ids
  def image_urls(size=:default)
    return nil unless is_a_digital_image?

    stacks_url = Settings.STACKS_URL

    image_ids = self["img_info"] || self["file_id"]

    image_ids.map do |image_id|
      image_id = image_id.gsub(/\.jp2$/, '')

      "#{stacks_url}/#{self["id"]}/#{image_id}#{SolrDocument.image_dimensions[size]}"
    end
  end

  # Size definitions for stacks urls
  def self.image_dimensions(size=:default)
    {
      :thumbnail => "_square",
      :default   => "?w=80&h=80",
      :medium    => "?w=125&h=125",
      :large     => "_thumb"
    }
  end


end
