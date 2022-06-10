# frozen_string_literal: true

module Eds
  # SearchService returns search results and fetches from the repository
  class SearchService
    # include Blacklight::RequestBuilders

    def initialize(blacklight_config, user_params = {}, eds_params = {})
      @blacklight_config = blacklight_config
      @user_params = user_params
      @repository = @blacklight_config.repository_class.new(@blacklight_config)
      @eds_params = eds_params
      @context = {}
    end

    attr_reader :blacklight_config, :user_params, :context # used by search_builder

    def search_builder
      blacklight_config.search_builder_class.new(self)
    end

    def search_state_class
      Blacklight::SearchState
    end

    def search_results
      builder = search_builder.with(user_params)
      builder = yield(builder) if block_given?
      response = @repository.search(builder, @eds_params)
      [response, response.documents]
    end

    def previous_and_next_documents_for_search(index, request_params, extra_controller_params = {})
      params, prev_hit, next_hit = previous_and_next_document_params(index)
      query = search_builder.with(request_params).merge(extra_controller_params).merge(params)
      response = @repository.search(query)
      document_list = response.documents
      prev_doc = document_list[prev_hit] if prev_hit.present? && !prev_hit.negative?
      next_doc = document_list[next_hit] if next_hit.present? && (next_hit + 1) <= response.total
      [response, [prev_doc, next_doc]]
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

    private

    ##
    # Pagination parameters for selecting the previous and next documents
    # out of a result set.
    def previous_and_next_document_params(index)
      raise ArgumentError, "Negative index: #{index}" if index.negative?

      eds_params = {}
      # we don't know the max number of results at this point so it's handled in the caller after the query is issued
      window = PagingWindow.new(index, 999_999_999)
      eds_params[:page_number] = window.start_page
      eds_params[:results_per_page] = window.per_page
      [eds_params, window.prev_hit, window.next_hit]
    end

    class PagingWindow
      attr_reader :start_page, :per_page, :prev_hit, :next_hit, :hit, :max
      def initialize(hit, max)
        @hit = hit
        @max = max
        @per_page = 10 # default page size so caching kicks in more often than not
        calculate!
      end

      private

      ##
      # EDS doesn't support searching by the first hit like Solr, so we need to figure out
      # the page on which both the previous and next hits lie relative to the given `hit`
      # (which is the hit of the current article of interest).
      #
      # @param [Integer] `hit` - 0-based hit index
      # @param [Integer] `max` - 1-based maximum hit
      # @return [start_page, per_page, prev_hit, next_hit] `hits` are relative to the page
      def calculate!
        raise ArgumentError, 'Cannot search for negative index' if hit.negative?
        raise ArgumentError, "Cannot search for hits for #{hit + 1} > #{max}" if hit + 1 > max

        page_index = set_window # initialize window

        if hit < (max - 1) # then we should have a next hit
          while page_index == (per_page - 1) # hit is last on this page, so increment per_page and recalculate
            page_index = set_window(1)
          end
        end

        if start_page.positive? && page_index.zero? # then we should have a previous hit, but might not on this page
          while page_index.zero? || page_index == (per_page - 1) # hit is the first on this page, so increment per_page to move it down
            page_index = set_window(1)
          end
        end

        @start_page += 1 # convert from 0-based to 1-based
        @prev_hit = hit.positive?   ? page_index - 1 : nil
        @next_hit = hit < (max - 1) ? page_index + 1 : nil
      end

      # Note that start_page and hit are 0-based here
      # @return [Integer] `page_index` - 0-based hit index on page
      def set_window(increment = 0)
        @per_page += increment
        @start_page = (hit / per_page).floor
        hit % per_page
      end
    end
  end
end
