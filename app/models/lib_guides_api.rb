# frozen_string_literal: true

class LibGuidesApi
  attr_reader :query

  class << self
    alias fetch new
  end

  def initialize(query)
    @query = query
  end

  # We make this response look like a blacklight catalog response
  def as_json(*)
    { meta: { pages: { total_count: json.count } } }
  end

  private

  def json
    JSON.parse(response)
  rescue JSON::ParserError => e
    Honeybadger.notify("Parsing LibGuides JSON response at #{url} failed with #{e}")
    []
  end

  def response
    @response ||= begin
      http = Faraday.get(url)

      if http.success?
        http.body
      else
        '[]'
      end
    end
  rescue Faraday::ConnectionFailed => e
    Honeybadger.notify("Parsing LibGuides JSON response at #{url} failed with #{e}")
    '[]'
  end

  def url
    [
      Settings.LIB_GUIDES.API_URL.to_s,
      '?',
      {
        site_id: Settings.LIB_GUIDES.SITE_ID,
        key: Settings.LIB_GUIDES.KEY,
        status: 1,
        sort_by: 'relevance'
      }.to_query,
      "&search_terms=#{CGI.escape(query)}"
    ].join
  end
end
