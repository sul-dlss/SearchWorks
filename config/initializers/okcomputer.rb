require 'okcomputer'

class PerformanceCheck < OkComputer::Check
  attr_reader :policy
  def initialize(policy)
    super()
    @policy = policy
  end

  def check
    if PerformanceAlerts.for(policy_id: policy.id).open.none?
      mark_message "No open #{policy.label} alerts"
    else
      mark_failure
      mark_message "There is an open #{policy.label} alert"
    end
  end
end

class OkapiCheck < OkComputer::Check
  def check
    if FolioClient.new.ping
      mark_message 'Connected to OKAPI'
    else
      mark_failure
      mark_message 'Unable to connect to OKAPI'
    end
  end
end

# /status for 'upness', e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# REQUIRED checks, required to pass for /status/all
#  individual checks also avail at /status/<name-of-check>
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new
OkComputer::Registry.register 'rails_cache', OkComputer::GenericCacheCheck.new

env = ENV['RAILS_ENV'] || 'test'
solr_url = Blacklight.blacklight_yml[env]['url']
OkComputer::Registry.register 'sw_solr', OkComputer::HttpCheck.new(solr_url + "/admin/ping")

# TODO:  add required checks
# mailer

# ------------------------------------------------------------------------------

# NON-CRUCIAL (Optional) checks, avail at /status/<name-of-check>
#   - at individual endpoint, HTTP response code reflects the actual result
#   - in /status/all, these checks will display their result text, but will not affect HTTP response code
# TODO:  add non-crucial checks:
# PURL_EMBED_RESOURCE
# PURL_EMBED_PROVIDER
# stacks
# hours api
# SSRC_REQUESTS_URL

Rails.application.reloader.to_prepare do
  OkComputer::Registry.register('live_lookups', OkapiCheck.new) if Settings.folio.url
  OkComputer::Registry.register 'oclc_citation_service', OkComputer::HttpCheck.new(Citation.test_api_url)

  Settings.NEW_RELIC_API.policies.each do |policy|
    OkComputer::Registry.register policy.key, PerformanceCheck.new(policy)
  end

  OkComputer.make_optional(%w[live_lookups oclc_citation_service]).concat(
    Settings.NEW_RELIC_API.policies.map(&:key)
  )
end
