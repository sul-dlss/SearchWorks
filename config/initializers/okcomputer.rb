require 'okcomputer'

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
solr_url = Blacklight.solr_yml[env]['url']
OkComputer::Registry.register 'sw_solr', OkComputer::SolrCheck.new(solr_url)

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
# LIVE_LOOKUP_URL
# STACKMAP_API_URL
# BOOKPLATES_EXHIBIT_URL
# OCLC.BASE_URL
