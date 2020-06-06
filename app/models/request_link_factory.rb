# frozen_string_literal: true

class RequestLinkFactory
  def self.for(library:)
    case library
    when 'HOOVER'
      RequestLinks::HooverRequestLink
    when 'HV-ARCHIVE'
      RequestLinks::HooverArchiveRequestLink
    else
      RequestLink
    end
  end
end
