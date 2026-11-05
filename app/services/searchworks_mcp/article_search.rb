# frozen_string_literal: true

module SearchworksMcp
  # Article search functionality exposed through MCP.
  module ArticleSearch
    extend self

    MAX_QUERY_LENGTH = 1000

    SEARCH_FIELDS = {
      "all_fields" => "search",
      "title" => "title",
      "author" => "author",
      "subject" => "subject"
    }.freeze

    # EDS limiter labels, as shown in the search settings on the articles results page
    FULL_TEXT_LIMITER = "Direct access to full text"
    PEER_REVIEWED_LIMITER = "Scholarly & peer-reviewed only"

    MAX_SOURCE_TYPE_LENGTH = 100
    # Bounds for an open-ended date range; EDS requires both ends (see Eds::SearchBuilder#add_date_slider)
    EARLIEST_YEAR = 1000

    INPUT_SCHEMA = {
      properties: {
        query: {
          type: "string",
          description: "The search query to find articles",
          minLength: 1, maxLength: MAX_QUERY_LENGTH
        },
        search_field: {
          type: "string",
          description: "The field to search in (defaults to all_fields)",
          enum: %w[all_fields title author subject]
        },
        rows: {
          type: "integer",
          description: "Number of results to return (defaults to 10, max 20)",
          minimum: 1, maximum: 20
        },
        start_year: {
          type: "integer",
          description: "Only return articles published in or after this year",
          minimum: EARLIEST_YEAR, maximum: 9999
        },
        end_year: {
          type: "integer",
          description: "Only return articles published in or before this year",
          minimum: EARLIEST_YEAR, maximum: 9999
        },
        source_type: {
          type: "string",
          description: "Filter by source type, e.g. \"Academic Journals\", \"Magazines\", \"News\", \"Books\", " \
                       "\"Reports\", \"Conference Materials\", or \"Dissertations\". Values are case-sensitive " \
                       "and must match exactly; choose them from the source type facet in returned results.",
          maxLength: MAX_SOURCE_TYPE_LENGTH
        },
        full_text_only: { type: "boolean", description: "Only return articles with direct access to full text (defaults to false)" },
        peer_reviewed_only: { type: "boolean", description: "Only return scholarly and peer-reviewed articles (defaults to false)" }
      },
      required: ["query"],
      additionalProperties: false
    }.freeze

    def search(query:, search_field: "all_fields", rows: 10, start_year: nil, end_year: nil, source_type: nil, # rubocop:disable Metrics/ParameterLists
               full_text_only: false, peer_reviewed_only: false)
      return disabled_response unless Settings.EDS_ENABLED

      filters = applied_filters(start_year:, end_year:, source_type:, full_text_only:, peer_reviewed_only:)
      params = search_params(query, search_field, rows, filters)
      response = run_search(params)
      unfiltered = run_search(params.except(:f, :range).merge(per_page: 1)) if filters.any? && response.total.zero?
      ArticleResults.format(response:, query:, search_field:, filters:, unfiltered_response: unfiltered)
    rescue StandardError => e
      SearchworksMcp.internal_tool_error(e, public_message: "Article search is temporarily unavailable.")
    end

    private

    def disabled_response
      {
        text: "Article search is not currently enabled. EDS (EBSCO Discovery Service) must be configured.",
        structured_content: { error: "EDS not enabled" },
        error: true
      }
    end

    # Normalizes the filter arguments, dropping unset ones, so they can be echoed back to the client.
    def applied_filters(filters)
      start_year, end_year = [filters[:start_year], filters[:end_year]].map { |year| year.presence&.to_i }
      start_year, end_year = end_year, start_year if start_year && end_year && start_year > end_year

      {
        start_year: start_year,
        end_year: end_year,
        source_type: filters[:source_type].presence,
        full_text_only: filters[:full_text_only].presence,
        peer_reviewed_only: filters[:peer_reviewed_only].presence
      }.compact
    end

    def search_params(query, search_field, rows, filters)
      params = {
        q: query,
        search_field: SEARCH_FIELDS.fetch(search_field, "search"),
        # Eds::SearchBuilder reads per_page (not rows) for ResultsPerPage
        per_page: rows.to_i.clamp(1, 20)
      }
      facet_filters = facet_filter_params(filters)
      params[:f] = facet_filters if facet_filters.any?
      params[:range] = { pub_year_tisim: year_range(filters) } if filters[:start_year] || filters[:end_year]
      params
    end

    def facet_filter_params(filters)
      limiters = []
      limiters << FULL_TEXT_LIMITER if filters[:full_text_only]
      limiters << PEER_REVIEWED_LIMITER if filters[:peer_reviewed_only]

      params = {}
      params["eds_search_limiters_facet"] = limiters if limiters.any?
      params["eds_publication_type_facet"] = [filters[:source_type]] if filters[:source_type]
      params
    end

    def year_range(filters)
      {
        begin: (filters[:start_year] || EARLIEST_YEAR).to_s,
        end: (filters[:end_year] || (Time.zone.now.year + 1)).to_s
      }
    end

    def run_search(params)
      eds_params = {
        guest: true,
        session_token: Eds::Session.new(guest: true, caller: "mcp-server").session_token
      }
      Eds::SearchService.new(ArticlesController.blacklight_config, params, eds_params).search_results
    end
  end
end
