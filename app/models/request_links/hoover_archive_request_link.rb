# frozen_string_literal: true

module RequestLinks
  class HooverArchiveRequestLink < RequestLink
    def present?
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
      if url
        "<a href=\"#{url}\" rel=\"nofollow\" class=\"btn btn-default btn-xs request-button\">#{link_text}</a>"
      else
        'Not available to request'
      end
    end
  end
end
