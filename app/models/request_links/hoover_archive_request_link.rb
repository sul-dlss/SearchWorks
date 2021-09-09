# frozen_string_literal: true

module RequestLinks
  class HooverArchiveRequestLink < RequestLink
    def show_location_level_request_link?
      true
    end

    def url
      return if available_via_temporary_access?

      document&.index_links&.finding_aid&.first&.href
    end

    private

    def link_text
      'Request via Finding Aid'
    end

    def markup
      if url
        "<a href=\"#{url}\" rel=\"nofollow\" class=\"#{classes}\">#{link_text}</a>"
      else
        'Not available to request'
      end
    end
  end
end
