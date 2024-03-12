# frozen_string_literal: true

require 'English'
class LaneProxyBuilder
  URI = 'https://lane.stanford.edu/eresources/ezproxy-servers.txt'
  PREFIX = 'T '
  FILENAME = 'config/ezproxy/lane_proxy_file.txt'

  def self.run
    new.run
  end

  def run
    result = Faraday.get(URI)
    raise "Unable to fetch #{URI}" unless result.success?

    lines = result.body.split($INPUT_RECORD_SEPARATOR)
    # filter only the lines that start with "T "
    lines = lines.filter_map { |line| line.delete_prefix(PREFIX) if line.start_with?(PREFIX) }
    File.write(FILENAME, lines.join($INPUT_RECORD_SEPARATOR))
  end
end
