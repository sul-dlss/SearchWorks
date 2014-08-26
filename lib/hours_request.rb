class HoursRequest

  def initialize(library)
    @library = library
    @hours_response = parse_response
  end

  def parse_hours
    if @hours_response.present? && !(@hours_response.has_key?('error'))
      { hours: "Today's hours:#{opens_at} - #{closes_at}".gsub('m', '').gsub(':00', '') }
    else
      @hours_response
    end
  end

  def parse_response
    return begin
      @hours_response = JSON.parse(get).first
    rescue JSON::ParserError => e
      @hours_response = nil
    end
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
      [{ error: 'No public access' }].to_json
    end
  end

  def opens_at
    Time.parse(@hours_response['opens_at']).strftime('%l:%M%P').to_s
  end

  def closes_at
    Time.parse(@hours_response['closes_at']).strftime('%l:%M%P').to_s
  end
end
