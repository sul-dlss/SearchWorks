# frozen_string_literal: true

module QuickSearch
  class ApplicationSearcher
    attr_accessor :http, :q

    class_attribute :search_service

    delegate :results, :total, to: :search

    def initialize(http_client, q)
      @http = http_client
      @q = q
    end

    def search
      @search ||= search_service.new(http: http).search(q)
    end

    def see_all_link
      format(see_all_url_template, q: CGI.escape(q))
    end
  end
end
