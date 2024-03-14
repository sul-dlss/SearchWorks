# frozen_string_literal: true

set :bundle_without, %w[sqlite development test].join(' ')

# alias searchworks-preview
server 'sw-webapp-sandbox-a.stanford.edu', user: 'blacklight', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
