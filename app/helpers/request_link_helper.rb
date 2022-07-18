module RequestLinkHelper
  def request_url(document, library:, location:, **request_params)
    "#{Settings.REQUESTS_URL}?#{request_params.merge(item: document.id, origin: library, origin_location: location).to_query}"
  end
end
