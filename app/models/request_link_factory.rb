# frozen_string_literal: true

class RequestLinkFactory
  class << self
    def for(library:, location:)
      case library
      when 'HOOVER'
        RequestLinks::HooverRequestLink
      when 'HV-ARCHIVE'
        RequestLinks::HooverArchiveRequestLink
      when 'HOPKINS'
        RequestLinks::HopkinsRequestLink
      else
        RequestLink
        # for_location(location)
      end
    end

    private

    def for_location(location)
      case location
      when 'SSRC-DATA'
        RequestLinks::SsrcDataRequestLink
      else
        RequestLink
      end
    end
  end
end
