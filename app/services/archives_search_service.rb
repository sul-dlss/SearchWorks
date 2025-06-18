# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts fields
class ArchivesSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.archives.api_url
    options[:response_class] ||= Response
    super
  end

  class Response < AbstractSearchService::Response
    def total
      json['meta']['pages']['total_count'].to_i
    end

    def results
      solr_docs = json['data']
      solr_docs.collect do |doc|
        attributes = doc['attributes']
        values = attributes.dig('breadcrumbs', 'attributes', 'value')
        ArchivesResult.new(
          link: doc['links']['self'],
          icon: icon(doc['type']),
          title: attributes['title'],
          description: values['scopecontent_tesim']&.first,
          physical: values['extent_ssm']&.first || doc['type']
        )
      end
    end

    def icon(type)
      case type
      when 'collection'
        'archive.svg'
      when 'Series'
        'folder.svg'
      when 'File', 'Item'
        'file.svg'
      end
    end
  end
end
