module RequestLinkHelper
  # @param [SolrDocument] document
  # @param [String] library the Symphony library code (e.g. 'GREEN')
  # @param [String] origin_location the Symphony location code (e.g. 'SSRC-SSDS')
  # @param [String] location the Folio location code (e.g. 'GRE-STACKS')
  # You must provide both library & origin_location OR location
  def request_url(document, library: nil, origin_location: nil, location: nil, **request_params)
    query = request_params.merge(item_id: document.id, origin: library, origin_location:, location:).to_query
    "#{Settings.REQUESTS_URL}?#{query}"
  end
end
