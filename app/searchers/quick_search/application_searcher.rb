# frozen_string_literal: true

module QuickSearch
  class ApplicationSearcher
    attr_accessor :http, :q

    class_attribute :search_service

    delegate :results, :total, to: :search

    include ActionView::Helpers::TextHelper

    def initialize(http_client, q, _per_page = nil)
      @http = http_client
      @q = q
    end

    def search
      @search ||= search_service.new(http: http).search(q)
    end

    def see_all_link
      format(see_all_url_template, q: CGI.escape(q))
    end

    private

    def filter_query(query)
      if query.match(/ -$/)
        query = query.sub(/ -$/,"")
      end
      query.gsub!('*', ' ')
      query.gsub!('!', ' ')
      query.gsub!('-', ' ') # Solr returns an error if multiple dashes appear at start of query string
      query.gsub!('\\', '')
      # query.gsub!('"', '')
      query.strip!
      query.squish!
      query.downcase! # FIXME: Do we really want to downcase everything?
      query = truncate(query, length: 100, separator: ' ', omission: '', escape: false)

      query
    end
  end
end
