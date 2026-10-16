# frozen_string_literal: true

require 'net/http'

# Run Solr with docker compose when it's available, otherwise with solr_wrapper.
def with_solr(&)
  if system('docker compose version', out: File::NULL, err: File::NULL)
    begin
      puts 'Starting Solr'
      system('docker compose up -d solr', exception: true)
      wait_for_solr
      yield
    ensure
      puts 'Stopping Solr'
      system('docker compose stop solr')
    end
  else
    require 'solr_wrapper'

    SolrWrapper.wrap do |solr|
      Rake::Task['searchworks:copy_solr_dependencies'].invoke
      solr.with_collection(name: 'blacklight-core', &)
    end
  end
end

# `docker compose up -d` returns before Solr has created the core.
def wait_for_solr(timeout: 60)
  ping = URI("http://127.0.0.1:#{ENV.fetch('SOLR_PORT', 8983)}/solr/blacklight-core/admin/ping")
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

  until solr_ping?(ping)
    raise "Solr did not respond at #{ping} within #{timeout} seconds" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

    sleep 1
  end
end

def solr_ping?(uri)
  Net::HTTP.get_response(uri).is_a?(Net::HTTPSuccess)
rescue StandardError
  false
end
