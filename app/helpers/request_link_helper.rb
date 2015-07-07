module RequestLinkHelper
  def request_link(document, callnumber)
    if callnumber.home_location == 'SSRC-DATA'
      request_params = ssrc_params(document, callnumber)
      "#{Settings.SSRC_REQUESTS_URL}?#{request_params.to_query}"
    else
      request_params = process_request_params(document, callnumber)
      "#{Settings.REQUESTS_URL}?#{request_params.to_query}"
    end
  end

  private

  def process_request_params(document, callnumber)
    request_params = request_options(document, callnumber)
    request_params.delete(:item_id) if Holdings::Library.new(callnumber.library, document).location_level_request?
    if callnumber.on_order?
      request_params.delete(:item_id)
      request_params.delete(:home_lib)
    end
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
      ckey:         document[:id],
      item_id:      callnumber.barcode,
      home_lib:     callnumber.library,
      home_loc:     callnumber.home_location,
      current_loc:  current_or_home_location(callnumber)
    }
  end

  def current_or_home_location(callnumber)
    return callnumber.current_location.code if callnumber.current_location.code.present?
    callnumber.home_location
  end
end
