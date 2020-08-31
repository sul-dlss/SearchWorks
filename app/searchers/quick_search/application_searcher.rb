# frozen_string_literal: true

module QuickSearch
  class ApplicationSearcher
    attr_accessor :response, :results_list, :total, :http, :q, :loaded_link

    include ActionView::Helpers::TextHelper

    def initialize(http_client, q, _per_page = nil)
      @http = http_client
      @q = q
    end

    # Returns the "loaded_link" when an error occurs, either from an I18N locale
    # file, or the "loaded_link" method on the searcher.
    #
    # Using the I18N locale files is considered legacy behavior (but
    # is preferred in this method to preserve existing functionality).
    #
    # Parameters:
    #  - service_name: The name of the searcher as used by the I18N locale files
    #  - error: The StandardError/SearcherError object
    #  - query: The search term being queried
    def self.module_link_on_error(service_name, error, query)
      if I18n.exists?("#{service_name}_search.loaded_link")
        # Preserve legacy behavior of using "loaded_link" from I18n locale file
        return I18n.t("#{service_name}_search.loaded_link") + ERB::Util.url_encode("#{query}")
      elsif error.is_a? QuickSearch::SearcherError
        searcher_obj = error.searcher
        return searcher_obj.loaded_link
      end
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
