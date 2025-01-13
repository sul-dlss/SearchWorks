# frozen_string_literal: true

##
# See https://github.com/kickstarter/rack-attack/blob/master/docs/example_configuration.md
# for more configuration options

### Throttle Spammy Clients ###

# If any single client IP is making tons of requests, then they're
# probably malicious or a poorly-configured scraper. Either way, they
# don't deserve to hog all of the app server's CPU. Cut them off!
#
# Note: If you're serving assets through rack, those requests may be
# counted by rack-attack and this throttle may be activated too
# quickly. If so, enable the condition to exclude them from tracking.

if Settings.THROTTLE_TRAFFIC
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: Settings.throttling.redis_url) if Settings.throttling.redis_url

  Rack::Attack.throttle('req/search/ip', limit: 15, period: 1.minute) do |req|
    route = begin
      Rails.application.routes.recognize_path(req.path) || {}
    rescue StandardError
      {}
    end

    req.ip if route[:controller] == 'catalog' && ['index', 'facet'].include?(route[:action])
  end

  Rack::Attack.throttle('req/view/ip', limit: 500, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/view')
  end

  # Throttle article searching more aggressively
  Rack::Attack.throttle('articles/search/ip', limit: 50, period: 5.minutes) do |req|
    route = begin
      Rails.application.routes.recognize_path(req.path) || {}
    rescue StandardError
      {}
    end

    req.ip if route[:controller] == 'articles' && route[:action] == 'index'
  end

  Rack::Attack.throttle('articles/view/ip', limit: 500, period: 5.minutes) do |req|
    route = begin
      Rails.application.routes.recognize_path(req.path) || {}
    rescue StandardError
      {}
    end

    req.ip if route[:controller] == 'articles' && route[:action] == 'show'
  end

  Rack::Attack.throttle('req/actions/ip', limit: 15, period: 1.minute) do |req|
    route = begin
      Rails.application.routes.recognize_path(req.path) || {}
    rescue StandardError
      {}
    end

    req.ip if route[:action].in? %w[email sms citation fulltext_link]
  end

  # Throttle article searching based on badly behaved user agent (device farm)?
  # Bots seem to be rotating IPs or using multiple devices as of April 2023
  # See error reports e.g. https://app.honeybadger.io/projects/50022/faults/34763067
  Rack::Attack.throttle('articles/user-agent', limit: 60, period: 5.minutes) do |req|
    req.user_agent if req.path.start_with?('/articles') &&
                      (!req.user_agent || req.user_agent.start_with?('Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T)'))
  end

  # Inform throttled clients about limits and when they will get out of jail
  Rack::Attack.throttled_response_retry_after_header = true
  Rack::Attack.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]

    if Settings.SEND_THROTTLE_NOTIFICATIONS_TO_HONEYBADGER &&
       (((match_data[:limit] - match_data[:count]) < 5) || (match_data[:count] % 10).zero?) &&
       !request.ip&.start_with?(/15\d\./) && # ignore abuse from hwclouds (among others)
       request.env['HTTP_REFERER'] != "https://google.com" # ignore abuse from bots
      Honeybadger.notify("Throttling request", context: { ip: request.ip, path: request.path }.merge(match_data))
    end

    headers = {
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s
    }

    [429, headers, ["Throttled\n"]]
  end

  Settings.throttling.safelist.each do |ip_range|
    Rack::Attack.safelist_ip(ip_range)
  end
end
