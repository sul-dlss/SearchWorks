# frozen_string_literal: true

module RequestLinks
  class HooverRequestLink < RequestLink
    def show_location_level_request_link?
      true
    end

    def url
      HooverOpenUrlRequest.new(library, document).to_url
    end

    private

    def link_params
      { data: { toggle: 'tooltip', html: 'true', title: I18n.t('searchworks.request_link.aeon_note') } }
    end

    def link_text
      'Request on-site access'
    end
  end
end
