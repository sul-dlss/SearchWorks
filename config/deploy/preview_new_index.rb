set :bundle_without, %w[sqlite development test].join(' ')

# For testing new index
server 'sw-webapp-sandbox-e.stanford.edu', user: 'blacklight', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
