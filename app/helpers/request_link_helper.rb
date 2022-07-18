module RequestLinkHelper
  def request_url(document, library:, location:, callnumber: nil, **request_params)
    if callnumber
      request_link(document, callnumber, callnumber.barcode)
    else
      "#{Settings.REQUESTS_URL}?#{request_params.merge(item: document.id, origin: library, origin_location: location).to_query}"
    end
  end

  def link_to_request_link(options = {})
    url = request_link(options[:document], options[:callnumber], options[:barcode])
    return unless url

    link_to(
      request_link_text(options[:callnumber], options[:library]),
      url,
      target: request_link_target,
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

  def request_link_text(callnumber, library)
    locale_key = "searchworks.request_link.#{library.try(:code) || 'default'}"
    locale_key = 'searchworks.request_link.request_on_site' if Constants::REQUEST_ONSITE_LOCATIONS.include?(callnumber.home_location)
    t(
      locale_key,
      default: :'searchworks.request_link.default'
    )
  end

  def request_link_target
    '_blank'
  end

  def link_data_attributes(callnumber)
    return unless callnumber

    if Constants::HOOVER_LIBS.include?(callnumber.library)
      { toggle: 'tooltip', html: 'true', title: t('searchworks.request_link.aeon_note') }
    elsif callnumber.home_location == 'SSRC-DATA'
      {}
    else
      {} # { behavior: 'requests-modal' } Removing modal since login screwed us
    end
  end

  def hoover_request_url(document, callnumber)
    HooverOpenUrlRequest.new(callnumber.library, document).to_url
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
      title_in: document_presenter(document).heading,
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
