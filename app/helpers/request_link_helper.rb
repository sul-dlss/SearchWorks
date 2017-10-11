module RequestLinkHelper
  def link_to_request_link(options = {})
    url = request_link(options[:document], options[:callnumber], options[:barcode])
    return unless url
    link_text = t(
      "searchworks.request_link.#{options[:library].try(:code) || 'default'}",
      default: :'searchworks.request_link.default'
    )
    link_to(
      link_text,
      url,
      target: request_link_target(options[:callnumber]),
      rel: 'nofollow',
      class: options[:class],
      data: link_data_attributes(options[:callnumber])
    )
  end

  def request_link(document, callnumber, barcode = nil)
    return unless callnumber
    return hoover_request_url(document, callnumber) if Constants::HOOVER_LIBS.include?(callnumber.library)
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

  def request_link_target(callnumber)
    return unless callnumber && Constants::HOOVER_LIBS.include?(callnumber.library)
    '_blank'
  end

  def link_data_attributes(callnumber)
    return { behavior: 'requests-modal' } unless callnumber && Constants::HOOVER_LIBS.include?(callnumber.library)

    { toggle: 'tooltip', html: 'true', title: t('searchworks.request_link.aeon_note') }
  end

  def hoover_request_url(document, callnumber)
    HooverOpenUrlRequest.new(callnumber.library, document, self).to_url
  end

  def process_request_params(document, callnumber, barcode)
    request_params = request_options(document, callnumber)
    request_params[:barcode] = barcode if barcode
    request_params
  end

  def ssrc_params(document, callnumber)
    {
      authid: '',
      unicorn_id_in: document[:id],
      title_in: show_presenter(document).heading,
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
