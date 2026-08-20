# frozen_string_literal: true

module SearchworksMcp
  # Detailed metadata for a single EDS article result.
  module ArticleRecord
    extend self

    def fetch(id:)
      return disabled_response unless Settings.EDS_ENABLED

      document = search_service.fetch(id)
      result = {
        id: document.id.to_s,
        title: document.eds_title,
        url: "https://searchworks.stanford.edu/articles/#{document.id}",
        metadata: {
          authors: document.eds_authors,
          source: document.eds_source_title,
          publication_date: document.eds_publication_date,
          publication_type: document.eds_publication_type || document.eds_document_type,
          abstract: document.eds_abstract,
          subjects: document.eds_subjects.map(&:to_s),
          languages: document.eds_languages,
          publisher: document.eds_publisher,
          doi: document.eds_document_doi,
          volume: document.eds_volume,
          issue: document.eds_issue,
          start_page: document.eds_page_start
        }.compact_blank
      }

      { text: record_text(result), structured_content: result }
    rescue StandardError => e
      {
        text: "Error retrieving article: #{e.message}",
        structured_content: { error: e.message },
        error: true
      }
    end

    private

    def search_service
      eds_params = {
        guest: true,
        session_token: Eds::Session.new(guest: true, caller: "mcp-server").session_token
      }
      Eds::SearchService.new(ArticlesController.blacklight_config, {}, eds_params)
    end

    def disabled_response
      {
        text: "Article retrieval is not currently enabled. EDS must be configured.",
        structured_content: { error: "EDS not enabled" },
        error: true
      }
    end

    def record_text(result)
      lines = [result[:title], "URL: #{result[:url]}"]
      result[:metadata].each do |label, value|
        lines << "#{label.to_s.humanize}: #{Array(value).join('; ')}"
      end
      lines.join("\n")
    end
  end
end
