# frozen_string_literal: true

# SearchService returns search results from the repository
module Eds
  class SearchService
    include Blacklight::RequestBuilders

    def initialize(blacklight_config, user_params = {}, eds_params = {})
      @blacklight_config = blacklight_config
      @user_params = user_params
      @repository = blacklight_config.repository_class.new(blacklight_config)
      @eds_params = eds_params
    end

    attr_reader :blacklight_config # used by search_builder
    attr_reader :repository # used by tests

    def search_results
      builder = search_builder.with(@user_params)
      builder.page = @user_params[:page] if @user_params[:page]
      builder.rows = (@user_params[:per_page] || @user_params[:rows]) if @user_params[:per_page] || @user_params[:rows]

      builder = yield(builder) if block_given?
      response = @repository.search(builder, @eds_params)

      [response, nil]
    end

    # retrieve a document, given the doc id
    # @param [Array{#to_s},#to_s] id
    # @return [Blacklight::Solr::Response, Blacklight::SolrDocument] the solr response object and the first document
    def fetch(id = nil, extra_controller_params = {})
      if id.is_a? Array
        fetch_many(id, extra_controller_params) # TODO: port me over from EDS example
      else
        fetch_one(id, extra_controller_params)
      end
    end

    def fetch_one(id, extra_controller_params)
      solr_response = @repository.find id, extra_controller_params, @eds_params
      [solr_response, solr_response.documents.first]
    end

    ##
    # Get the solr response when retrieving only a single facet field
    # @return [Blacklight::Solr::Response] the solr response
    def facet_field_response(facet_field, extra_controller_params = {})
      query = search_builder.with(@user_params).facet(facet_field)
      @repository.search(query.merge(extra_controller_params), @eds_params)
    end
  end
end
