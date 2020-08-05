# frozen_string_literal: true

module QuickSearch
  class ApplicationSearcher
    attr_accessor :response, :results_list, :total, :http, :q, :per_page, :loaded_link, :offset, :page, :scope

    include QueryFilter

    # TODO: What should the method signature be?
    def initialize(http_client, q, per_page, offset = 0, page = 1, on_campus = false, scope = '', params = {})
      @http = http_client
      @q = q
      @per_page = per_page
      @page = page
      @offset = offset
      @on_campus = on_campus
      @scope = scope
    end
  end
end
