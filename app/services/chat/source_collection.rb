# frozen_string_literal: true

module Chat
  # Collects the records chat tools returned during a turn, so the answer's links can be
  # checked against them and the browser knows which URLs are verified.
  class SourceCollection
    def initialize
      @sources = {}
    end

    # @param content [Hash] a tool's structured content
    def add(content)
      return unless content.is_a?(Hash)

      content = content.deep_symbolize_keys
      Array(content[:results]).each { |record| add_record(record) }
      add_record(content) if content[:title]
    end

    def title_for(url)
      @sources[url]&.fetch(:title)
    end

    # Every collected source: the answer may cite any of them, and the browser only keeps links to these.
    def to_a
      @sources.values.first(Rails.configuration.x.chat.max_sources)
    end

    private

    def add_record(record)
      return if record[:url].blank? || record[:title].blank?

      @sources[record[:url]] ||= { id: record[:id], title: record[:title], url: record[:url] }.compact
    end
  end
end
