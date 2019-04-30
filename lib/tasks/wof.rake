require 'json'
require 'nokogiri'

namespace :wof do
  desc 'Getting LOC ids for strings'
  task update: [:environment] do
    geo_names = JSON.parse(
      File.read(
        Rails.root.join('top_10000_geographic.json')
      )
    )
    puts "#{geo_names.length} names found"
    conn = Faraday.new(url: 'https://id.loc.gov') do |b|
      b.use FaradayMiddleware::FollowRedirects
      b.adapter :net_http
    end
    lookup = {}
    geo_names.each do |name|
      response = conn.get do |req|
        req.url URI.encode("/authorities/label/#{name}")
        req.headers['Accept'] = 'application/json'
      end
      if response.headers['x-uri']&.include?('names')
        lookup[name] = response.headers['x-uri']
      else
        # Optimistically grab the first entry that begins with "n"
        response = conn.get do |req|
          req.url "/search/"
          req.options.params_encoder = Faraday::FlatParamsEncoder
          req.params['q'] = ["\"#{name}\"", 'rdftype:Geographic']
        end
        document = Nokogiri::HTML(response.body)
        loc_id = document.xpath('//td[starts-with(text(), "n")]')&.first&.text
        lookup[name] = "http://id.loc.gov/authorities/names/#{loc_id}" if loc_id.present? && loc_id.length > 5
      end
      puts "#{name} #{lookup[name]}"
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
    geo_lookup.each do |lookup|
      next unless lookup[1] && lookup[1].include?('names')

      loc_id = lookup[1].gsub('http://id.loc.gov/authorities/names/', '')
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
      puts "#{lookup[0]} #{wof_id}"
      geo_wof[lookup[0]] = {
        loc_id: loc_id,
        wof_id: wof_id
      } if wof_id.present?
    end
    File.open(Rails.root.join('wof_lookup.json'), 'w') { |f| f.write(geo_wof.to_json) }
  end
end
