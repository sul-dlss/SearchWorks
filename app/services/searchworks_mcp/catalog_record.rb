# frozen_string_literal: true

module SearchworksMcp
  # Detailed bibliographic metadata for a single catalog record.
  module CatalogRecord
    extend self

    MAX_ID_LENGTH = 255
    # Keys of a summary_struct/toc_struct entry that hold text
    STRUCT_TEXT_KEYS = %i[fields vernacular unmatched_vernacular].freeze

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

    # Flattens summary_struct/toc_struct entries into "Label: text" strings. Each entry has a label and
    # fields: summary fields are { field: [...], vernacular: "..." } hashes; TOC fields are lists of
    # contents items. Both may also carry vernacular and unmatched_vernacular text.
    def structured_text(value)
      Array(value).flat_map do |entry|
        next Array(struct_text(entry)) unless entry.is_a?(Hash)

        label = struct_key(entry, :label)
        texts = STRUCT_TEXT_KEYS.flat_map { |key| Array(struct_key(entry, key)) }
        texts.filter_map { |field| struct_text(field, " -- ") }.map { |text| [label, text].compact_blank.join(": ") }
      end
    end

    # Text of a struct field. Arrays are contents items (joined with separator), or the parts of a
    # summary; hashes are summary fields or tagged values like { link: url } and { source: text }.
    def struct_text(field, separator = " ")
      text = case field
             when Hash
               if field.key?(:field) || field.key?("field")
                 [struct_text(struct_key(field, :field)), struct_text(struct_key(field, :vernacular))].compact.join(" / ")
               else
                 field.values.filter_map { |value| struct_text(value) }.join(" ")
               end
             when Array
               field.filter_map { |item| struct_text(item) }.join(separator)
             else
               field.to_s
             end
      text.squish.presence
    end

    def struct_key(hash, key)
      hash[key] || hash[key.to_s]
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
