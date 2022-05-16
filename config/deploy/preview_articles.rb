set :bundle_without, %w[sqlite development test].join(' ')

server 'sw-webapp-sandbox-f.stanford.edu', user: 'blacklight', roles: %w[web db app]

# NOTE: Branch no longer deploys because of mimemagic version issue
# set :branch, 'linked-data-experiments'

set :linked_files, fetch(:linked_files, []) << 'wof_lookup.json'

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
