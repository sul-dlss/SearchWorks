# frozen_string_literal: true

module SearchworksMcp
  # Detailed metadata for a single EDS article result.
  module ArticleRecord
    module_function

    DISABLED_MESSAGE = "Article retrieval is not currently enabled. EDS must be configured."

    def fetch(id:)
      return ToolResult.failure(DISABLED_MESSAGE, error: "EDS not enabled") unless Settings.EDS_ENABLED

      document = SearchServices.eds.fetch(id)
      result = {
        id: document.id.to_s,
        title: document.eds_title.presence || "Untitled",
        url: Urls.article(document.id),
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

      ToolResult.success(TextFormat.record(result), result)
    rescue StandardError => e
      ToolResult.internal_error(e, public_message: "Article retrieval is temporarily unavailable.")
    end
  end
end
