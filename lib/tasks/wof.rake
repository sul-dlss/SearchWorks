require 'json'
require 'nokogiri'

def with_retry(times: 5, &block)
  return_value = times.times do |i|
    value = begin
      yield block
    rescue => e
      raise e if (i + 1) == times

      nil
    end
    return value if value
  end

  return_value == times ? nil : return_value
end

def uri_for_name_from_loc(connection:, name:)
  response = connection.get do |req|
    req.url "/authorities/label/#{URI.encode_www_form_component(name)}"
    req.headers['Accept'] = 'application/json'
  end

  if response.headers['x-uri']&.include?('names')
    response.headers['x-uri']
  else
    # Optimistically grab the first entry that begins with "n"
    response = connection.get do |req|
      req.url "/search/"
      req.options.params_encoder = Faraday::FlatParamsEncoder
      req.params['q'] = ["\"#{name}\"", 'rdftype:Geographic']
    end
    document = Nokogiri::HTML(response.body)
    loc_id = document.xpath('//td[starts-with(text(), "n")]')&.first&.text
    return unless loc_id.present? && loc_id.length > 5

    "http://id.loc.gov/authorities/names/#{loc_id}"
  end
end

namespace :wof do
  desc 'Getting LOC ids for strings'
  task update: [:environment] do
    geo_names = JSON.parse(
      File.read(
        Rails.root.join('top_10000_geographic.json')
      )
    )
    total = geo_names.length
    puts "#{total} names found"
    conn = Faraday.new(url: 'https://id.loc.gov') do |b|
      b.use FaradayMiddleware::FollowRedirects
      b.adapter :net_http
    end
    lookup = {}
    geo_names.each_with_index do |name, i|
      uri = with_retry { uri_for_name_from_loc(connection: conn, name: name) }
      if uri
        lookup[name] = uri
      end
      puts "#{i+1} of #{total}: #{name} (#{uri.inspect})"
    end
    File.open(Rails.root.join('geo_lookup.json'), 'w') { |f| f.write(lookup.to_json) }
  end
  desc 'Get the WoF id based of the LCNAF'
  task get_id: [:environment] do
    geo_lookup = JSON.parse(
      File.read(
        Rails.root.join('geo_lookup.json')
      )
    )
    geo_wof = {}
    total = geo_lookup.keys.length
    geo_lookup.each.with_index do |(location, uri), i|
      next unless uri && uri.include?('names')

      loc_id = uri.gsub('http://id.loc.gov/authorities/names/', '')
      conn = Faraday.new(url: 'https://spelunker.whosonfirst.org') do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end
      response = conn.get do |req|
        req.url '/search'
        req.params['q'] = loc_id
      end
      document = Nokogiri::HTML(response.body)
      wof_id = document.search('code').text
      puts "#{i+1} of #{total} #{location} #{wof_id}"
      geo_wof[location] = {
        loc_id: loc_id,
        wof_id: wof_id
      } if wof_id.present?
    end
    File.open(Rails.root.join('wof_lookup.json'), 'w') { |f| f.write(geo_wof.to_json) }
  end
end
