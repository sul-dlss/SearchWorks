module RequestLinkHelper
  def request_link(document, callnumber)
    request_query = request_options(document, callnumber)
    request_query.delete(:item_id) if Holdings::Library.new(callnumber.library).location_level_request?
    if callnumber.on_order?
      request_query.delete(:item_id)
      request_query.delete(:home_lib)
    end
    if callnumber.home_location == 'SSRC-DATA'
      "#{Settings.SSRC_REQUESTS_URL}?authid=&unicorn_id_in=#{CGI::escape(document[:id])}&title_in=#{CGI::escape(presenter(document).document_heading)}&icpsr_no_in=&call_no_in=#{CGI::escape(callnumber.callnumber)}"
    else
      "#{Settings.REQUESTS_URL}?#{request_query.to_query}"
    end
  end
  private
  def request_options(document, callnumber)
    {ckey:         CGI::escape(document[:id]),
     item_id:      CGI::escape(callnumber.barcode),
     home_lib:     CGI::escape(callnumber.library),
     home_loc:     CGI::escape(callnumber.home_location),
     current_loc:  CGI::escape(callnumber.current_location.code.present? ? callnumber.current_location.code : callnumber.home_location)}
  end
end
