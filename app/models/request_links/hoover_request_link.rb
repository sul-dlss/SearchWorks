# frozen_string_literal: true

module RequestLinks
  class HooverRequestLink < RequestLink
    def show_location_level_request_link?
      !available_via_temporary_access?
    end

    def url
      HooverOpenUrlRequest.new(library, document).to_url
    end

    private

    def tooltip
      "data-toggle=\"tooltip\" data-html=\"true\" data-title=\"#{I18n.t('searchworks.request_link.aeon_note')}\""
    end

    def link_text
      'Request on-site access'
    end

    def markup
      "<a href=\"#{url}\" rel=\"nofollow\" #{tooltip} class=\"#{classes}\">#{link_text}</a>"
    end
  end
end
