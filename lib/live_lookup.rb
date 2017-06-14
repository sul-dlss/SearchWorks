class LiveLookup
  HIDE_DUE_DATE_LIBS = ['RUMSEYMAP'].freeze

  delegate :to_json, to: :records
  def initialize(ids)
    @ids = [ids].flatten.compact
  end

  private

  def records
    @records ||= response.xpath('//record').map do |record|
      LiveLookup::Record.new(record).to_json
    end
  end

  def response
    @response ||= Nokogiri::XML(response_xml)
  end

  def response_xml
    @response_xml ||= begin
      conn = Faraday.new(url: live_lookup_url)
      conn.get do |request|
        request.options.timeout = 10
        request.options.open_timeout = 10
      end.body
    rescue Faraday::Error::ConnectionFailed
      nil
    rescue Faraday::Error::TimeoutError
      nil
    end
  end

  def live_lookup_url
    "#{Settings.LIVE_LOOKUP_URL}?#{live_lookup_query_params}"
  end

  def live_lookup_query_params
    if multiple_ids?
      "search=holdings&#{mapped_ids}"
    else
      "search=holding&id=#{@ids.first}"
    end
  end

  def mapped_ids
    @ids.each_with_index.map do |id, index|
      "id#{index}=#{id}"
    end.join('&')
  end

  def multiple_ids?
    @ids.length > 1
  end

  class Record
    def initialize(record)
      @record = record
    end

    def to_json
      {
        barcode: barcode,
        due_date: due_date,
        current_location: current_location
      }.to_json
    end

    def barcode
      @record.xpath('.//item_record/item_id').map(&:text).last
    end

    def due_date
      return unless valid_due_date?
      due_date_value.gsub(',23:59', '')
    end

    def due_date_value
      @record.xpath('.//item_record/date_time_due').map(&:text).last
    end

    def current_location
      return unless valid_current_location?
      Holdings::Location.new(current_location_code).name
    end

    def current_location_code
      @record.xpath('.//item_record/current_location').map(&:text).last
    end

    private

    def library_code
      @record.xpath('.//item_record/library').map(&:text).last
    end

    def home_location_code
      @record.xpath('.//item_record/home_location').map(&:text).last
    end

    def valid_current_location?
      return false if current_location_code.blank? ||
                      current_location_code == 'CHECKEDOUT' ||
                      current_location_same_as_home_location?
      true
    end

    def current_location_same_as_home_location?
      Holdings::Location.new(current_location_code).name == Holdings::Location.new(home_location_code).name
    end

    def valid_due_date?
      due_date_value.present? &&
        due_date_value != 'NEVER' &&
        !Constants::HIDE_DUE_DATE_CURRENT_LOCS.include?(current_location_code) &&
        !HIDE_DUE_DATE_LIBS.include?(library_code)
    end
  end
end
