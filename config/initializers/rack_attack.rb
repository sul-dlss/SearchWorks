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
