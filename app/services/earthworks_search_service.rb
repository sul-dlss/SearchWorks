# frozen_string_literal: true

# Uses the Blacklight JSON API to search and then extracts select Catalog fields
class EarthworksSearchService < AbstractSearchService
  def initialize(options = {})
    options[:query_url] ||= Settings.earthworks.api_url.to_s
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
        format = doc.dig('attributes', 'gbl_resourceClass_sm', 'attributes', 'value')
        EarthworksResult.new(
          title: doc.dig('attributes', 'title'),
          format: format,
          date: date(doc),
          coverage: coverage(doc),
          link: format(Settings.earthworks.fetch_url, id: doc['id']),
          author: doc.dig('attributes', 'dc_creator_sm', 'attributes', 'value'),
          description: doc.dig('attributes', 'dc_description_s', 'attributes', 'value')
        )
      end
    end

    private

    def date(doc)
      date = doc.dig('attributes', 'gbl_indexYear_im', 'attributes', 'value')

      return if date.blank?

      "Temporal Coverage: #{date}"
    end

    def coverage(doc)
      coverage = doc.dig('attributes', 'dct_spatial_sm', 'attributes', 'value')

      return if coverage.blank?

      "Place: #{coverage}"
    end
  end
end
