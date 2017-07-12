# frozen_string_literal: true

module Eds
  # SearchService returns search results and fetches from the repository
  class SearchService
    include Blacklight::RequestBuilders

    def initialize(blacklight_config, eds_params = {})
      @blacklight_config = blacklight_config
      @repository = @blacklight_config.repository_class.new(@blacklight_config)
      @eds_params = eds_params
    end

    attr_reader :blacklight_config # used by search_builder

    def search_results(user_params)
      builder = search_builder.with(user_params)
      builder = yield(builder) if block_given?
      response = @repository.search(builder, @eds_params)
      [response, response.documents]
    end

    # retrieve a document, given the doc id
    # @param [Array{#to_s},#to_s] id
    # @return [Blacklight::Solr::Response, Blacklight::SolrDocument] the solr response object and the first document
    def fetch(id = nil, extra_controller_params = {})
      raise NotImplementedError if id.is_a? Array
      fetch_one(id, extra_controller_params)
    end

    def fetch_one(id, extra_controller_params)
      solr_response = @repository.find id, extra_controller_params, @eds_params
      [solr_response, solr_response.documents.first]
    end
  end
end
