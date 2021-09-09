# frozen_string_literal: true

module RequestLinks
  class HooverArchiveRequestLink < RequestLink
    def show_location_level_request_link?
      true
    end

    def url
      document&.index_links&.finding_aid&.first&.href
    end

    private

    def link_text
      'Request via Finding Aid'
    end

    def markup
      return 'Not available to request' if available_via_temporary_access? || url.blank?

      super
    end
  end
end
