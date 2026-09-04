# frozen_string_literal: true

module SearchworksMcp
  # Detailed bibliographic metadata for a single catalog record.
  module CatalogRecord
    extend self

    MAX_ID_LENGTH = 255

    def fetch(id:, controller: nil)
      document = search_service(controller).fetch(id)
      result = {
        id: document.id.to_s,
        title: scalar(document, "title_display", "title_full_display") || "Untitled",
        url: "https://searchworks.stanford.edu/view/#{ERB::Util.url_encode(document.id.to_s)}",
        metadata: metadata(document)
      }

      { text: record_text(result), structured_content: result }
    rescue StandardError => e
      SearchworksMcp.internal_tool_error(e, public_message: "Catalog record retrieval is temporarily unavailable.")
    end

    private

    def search_service(controller)
      config = CatalogController.blacklight_config
      state = Blacklight::SearchState.new({}, config, controller)
      Blacklight::SearchService.new(config: config, search_state: state)
    end

    def metadata(document)
      {
        authors: values(document, "author_person_full_display", "author_person_display", "author_corp_display"),
        formats: values(document, "format_hsim", "format", "format_main_ssim"),
        publication: scalar(document, "imprint_display"),
        publication_years: values(document, "pub_year_tisim", "pub_date"),
        languages: values(document, "language"),
        subjects: values(document, "subject_all_search", "topic_facet"),
        genres: values(document, "genre_ssim"),
        call_numbers: values(document, "callnum_display", "callnum_search"),
        isbn: values(document, "isbn_display"),
        oclc: values(document, "oclc"),
        summaries: structured_text(document["summary_struct"]),
        contents: structured_text(document["toc_struct"])
      }.compact_blank
    end

    def scalar(document, *fields)
      values(document, *fields).first
    end

    def values(document, *fields)
      fields.lazy.map { |field| Array(document[field]).compact_blank }.find(&:present?) || []
    end

    def structured_text(value)
      Array(value).filter_map do |entry|
        case entry
        when Hash
          [entry[:label] || entry["label"], structured_text(entry[:fields] || entry["fields"] || entry[:value] || entry["value"])].compact_blank.join(": ")
        else
          entry.to_s.presence
        end
      end
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
