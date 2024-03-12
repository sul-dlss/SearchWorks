# frozen_string_literal: true

set :bundle_without, %w[sqlite development test].join(' ')

# Other aliases are sw-gryphon-search, gryphon-search, and searchworks-gryphon-search
server 'sw-webapp-sandbox-c.stanford.edu', user: 'blacklight', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
