# frozen_string_literal: true

module Chat
  # Converts exact bare references to verified sources into Markdown links.
  class CitationLinker
    # Shorter titles ("Report", "Poems") are too likely to appear in prose that isn't a citation.
    MIN_TITLE_LENGTH = 15

    MARKDOWN_LINK = /\[[^\]\n]+\]\((?:<[^>\n]+>|[^)\n]+)\)/

    def initialize(sources:)
      @sources = Array(sources).filter_map do |source|
        source = source.to_h.deep_symbolize_keys
        source if source[:title].to_s.length >= MIN_TITLE_LENGTH && source[:url].present?
      end
    end

    def call(answer)
      return answer if answer.blank? || @sources.empty?

      links = []
      protected_answer = answer.gsub(MARKDOWN_LINK) do |link|
        links << link
        placeholder(links.length - 1)
      end

      linked_answer = link_bare_references(protected_answer)
      links.each_with_index { |link, index| linked_answer.gsub!(placeholder(index), link) }
      linked_answer
    end

    private

    def link_bare_references(answer)
      sources_by_title = @sources.index_by { |source| source.fetch(:title) }
      titles = sources_by_title.keys.sort_by { |title| -title.length }
      pattern = Regexp.union(titles)

      answer.gsub(pattern) do |citation|
        source = sources_by_title.fetch(citation)
        "[#{escape_label(citation)}](<#{source.fetch(:url)}>)"
      end
    end

    def escape_label(text)
      text.gsub(/[\\\[\]]/) { |character| "\\#{character}" }
    end

    def placeholder(index)
      "\u0000verified-markdown-link-#{index}\u0000"
    end
  end
end
