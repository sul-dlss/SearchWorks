class HoursRequest
  def initialize(library)
    @library = library
  end

  def full_url
    "#{Settings.HOURS_API}/#{find_library}/hours/for/today"
  end

  def find_library
    Constants::HOURS_LOCATIONS[@library]
  end

  def get
    if find_library.present?
      begin
        Faraday.new(url: full_url).get.body
      rescue Faraday::Error::ConnectionFailed => e
        nil
      end
    else
      { error: 'No public access' }.to_json
    end
  end
end
