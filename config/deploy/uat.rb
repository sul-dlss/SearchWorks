# frozen_string_literal: true

set :bundle_without, %w[sqlite development test].join(' ')

# Aliased to searchworks-uat
server 'sw-webapp-sandbox-g.stanford.edu', user: 'blacklight', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
