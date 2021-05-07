# frozen_string_literal: true

module Eds
  # SearchService returns search results and fetches from the repository
  class SearchService
    def initialize(blacklight_config, user_params = {}, eds_params = {})
      @blacklight_config = blacklight_config
      @user_params = user_params
      @repository = @blacklight_config.repository_class.new(@blacklight_config)
      @eds_params = eds_params
    end

    def search_builder
      SearchBuilder.new(self)
    end

    attr_reader :blacklight_config, :user_params # used by search_builder

    def search_results
      builder = search_builder.with(user_params)
      builder = yield(builder) if block_given?
      response = @repository.search(builder, @eds_params)
      [response, response.documents]
    end

    # retrieve a document, given the doc id
    # @param [Array{#to_s},#to_s] id
    # @return [Blacklight::Solr::Response, Blacklight::SolrDocument] the solr response object and the first document
    def fetch(id = nil, extra_controller_params = {})
      if id.is_a? Array
        fetch_many(id, extra_controller_params)
      else
        fetch_one(id, extra_controller_params)
      end
    end

    ##
    # Retrieve a set of documents by id
    # @param [Array] ids
    # @param [HashWithIndifferentAccess] extra_controller_params
    def fetch_many(ids, extra_controller_params = {})
      solr_response = @repository.find_by_ids(ids, @eds_params)

      [solr_response, solr_response.documents]
    end

    ##
    # Retrieve a single document
    # @param [String] id
    # @param [HashWithIndifferentAccess] extra_controller_params
    def fetch_one(id, extra_controller_params)
      solr_response = @repository.find id, extra_controller_params, @eds_params
      [solr_response, solr_response.documents.first]
    end
  end
end
