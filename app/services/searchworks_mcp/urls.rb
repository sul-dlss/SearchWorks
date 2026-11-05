# frozen_string_literal: true

module SearchworksMcp
  # Canonical public SearchWorks URLs that tools return for citation.
  module Urls
    module_function

    BASE_URL = "https://searchworks.stanford.edu"

    def catalog(id)
      "#{BASE_URL}/view/#{ERB::Util.url_encode(id.to_s)}"
    end

    def article(id)
      "#{BASE_URL}/articles/#{ERB::Util.url_encode(id.to_s)}"
    end
  end
end
