# frozen_string_literal: true

class PerformanceAlerts
  def initialize(policy_id:, http_client: Faraday, logger: Rails.logger)
    @policy_id = policy_id
    @http_client = http_client
    @logger = logger
  end

  def open
    alerts.select do |alert|
      alert['opened_at'].present? && alert['closed_at'].blank?
    end
  end

  class << self
    alias for new
  end

  private

  attr_reader :http_client, :logger, :policy_id

  def alerts
    violations.select do |violation|
      violation.dig('links', 'policy_id').to_s == policy_id.to_s
    end
  end

  def violations
    @violations ||= begin
                      JSON.parse(response)['violations'] || []
                    rescue JSON::ParserError => e
                      logger.warn("Unable to parse PerformanceCheck JSON with: #{e}")
                      []
                    end
  end

  def response
    @response ||= begin
                    connection.get do |req|
                      req.url api_url
                      req.headers['X-Api-Key'] = api_key
                    end.body
                  rescue Faraday::ConnectionFailed => e
                    logger.warn("PerformanceCheck API request failed with: #{e}")
                    '{}'
                  end
  end

  def connection
    http_client.new
  end

  def api_url
    settings.alert_url
  end

  def api_key
    settings.api_key
  end

  def settings
    Settings.NEW_RELIC_API
  end
end
