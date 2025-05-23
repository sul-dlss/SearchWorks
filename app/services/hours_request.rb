# frozen_string_literal: true

# Proxy request from library-hours
class HoursRequest
  def initialize(library)
    @library = library
  end

  def full_url
    "#{Settings.HOURS_API.host}/#{find_library}/hours/for/today"
  end

  def find_library
    Settings.libraries[@library]&.hours_api_url
  end

  def get
    if find_library.present?
      return unless Settings.HOURS_API.enabled

      begin
        response = Faraday.new(url: full_url).get
        response.success? ? response.body : { error: 'unable to retrieve hours' }
      rescue Faraday::ConnectionFailed
        nil
      end
    else
      { error: 'No public access' }
    end
  end
end
