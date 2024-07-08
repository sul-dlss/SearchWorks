Rack::Attack.throttle('req/ip/1m', limit: 15, period: 1.minutes) do |req|
  req.ip if req.path == '/all'
end

Rack::Attack.throttle('req/ip/5m', limit: 50, period: 5.minutes) do |req|
  req.ip if req.path == '/all'
end

# Throttle catalog search and result requests by IP (10rpm over 1 minute)
  Rack::Attack.throttle('req/ip/catalog/1m', limit: 10, period: 1.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/catalog')
  end

  Rack::Attack.throttle('req/ip/article/1m', limit: 10, period: 1.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/article')
  end

  Rack::Attack.throttle('req/ip/earthworks/1m', limit: 10, period: 1.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/earthworks')
  end

  Rack::Attack.throttle('req/ip/exhibits/1m', limit: 10, period: 1.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/exhibits')
  end

    # Throttle catalog search and result requests by IP (6rpm over 5 minutes)
  Rack::Attack.throttle('req/ip/catalog/5m', limit: 30, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/catalog')
  end

  Rack::Attack.throttle('req/ip/article/5m', limit: 30, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/article')
  end

  Rack::Attack.throttle('req/ip/earthworks/5m', limit: 30, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/earthworks')
  end

  Rack::Attack.throttle('req/ip/exhibits/5m', limit: 30, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/all/xhr_search/exhibits')
  end

  Rack::Attack.throttled_response_retry_after_header = true

  Rack::Attack.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]

    headers = {
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s
    }

    [429, headers, ["Throttled\n"]]
  end

  # Disable throttling for Stanford-local users
  Rack::Attack.safelist_ip("171.64.0.0/14")
  Rack::Attack.safelist_ip("10.0.0.0/8")
  Rack::Attack.safelist_ip("172.16.0.0/12")
