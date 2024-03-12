# frozen_string_literal: true

module RequestLinkHelper
  # @param [SolrDocument] document
  # @param [String] library the Symphony library code (e.g. 'GREEN')
  # @param [String] location the Symphony location code (e.g. 'SSRC-SSDS')
  def request_url(document, library:, location:, **request_params)
    "#{Settings.REQUESTS_URL}?#{request_params.merge(item_id: document.id, origin: library, origin_location: location).to_query}"
  end
end
