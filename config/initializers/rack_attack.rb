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
  # Throttle catalog search and result requests by IP (60rpm)
  Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/catalog', '/view')
  end

  # Throttle article searching more aggressively to protect EDS API (12rpm)
  Rack::Attack.throttle('articles/ip', limit: 60, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/articles')
  end

  # Inform throttled clients about limits and when they will get out of jail
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
end
