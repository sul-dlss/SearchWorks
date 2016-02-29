module RequestLinkHelper
  def link_to_request_link(options = {})
    url = request_link(options[:document], options[:callnumber], options[:barcode])
    return unless url
    link_to(
      'Request',
      url,
      rel: 'nofollow',
      class: options[:class],
      data: { behavior: 'requests-modal' }
    )
  end

  def request_link(document, callnumber, barcode = nil)
    return unless callnumber
    if callnumber.home_location == 'SSRC-DATA'
      base_url = Settings.SSRC_REQUESTS_URL
      request_params = ssrc_params(document, callnumber)
    else
      base_url = Settings.REQUESTS_URL
      request_params = process_request_params(document, callnumber, barcode)
    end
    "#{base_url}?#{request_params.to_query}"
  end

  private

  def process_request_params(document, callnumber, barcode)
    request_params = request_options(document, callnumber)
    request_params[:barcode] = barcode if barcode
    request_params
  end

  def ssrc_params(document, callnumber)
    {
      authid: '',
      unicorn_id_in: document[:id],
      title_in: presenter(document).document_heading,
      icpsr_no_in: '',
      call_no_in: callnumber.callnumber
    }
  end

  def request_options(document, callnumber)
    {
      item_id: document[:id],
      origin: callnumber.library,
      origin_location: callnumber.home_location
    }
  end
end
