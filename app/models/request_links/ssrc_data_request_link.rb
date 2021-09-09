# frozen_string_literal: true

module RequestLinks
  class SsrcDataRequestLink < RequestLink
    def show_location_level_request_link?
      true
    end

    def url
      "#{Settings.SSRC_REQUESTS_URL}?#{request_params.to_query}"
    end

    private

    def link_text
      'Request'
    end

    def markup
      "<a href=\"#{url}\" rel=\"nofollow\" class=\"#{classes}\">#{link_text}</a>"
    end

    def request_params
      {
        authid: '',
        unicorn_id_in: document[:id],
        title_in: document.first('title_display'),
        icpsr_no_in: '',
        call_no_in: items&.first&.callnumber
      }
    end
  end
end
