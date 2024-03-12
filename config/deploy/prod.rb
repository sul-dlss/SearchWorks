# frozen_string_literal: true

set :bundle_without, %w[sqlite development test].join(' ')

server 'sw-webapp-a.stanford.edu', user: 'blacklight', roles: %w[web db app]
server 'sw-webapp-b.stanford.edu', user: 'blacklight', roles: %w[web db app]
server 'sw-webapp-c.stanford.edu', user: 'blacklight', roles: %w[web db app]
server 'sw-webapp-d.stanford.edu', user: 'blacklight', roles: %w[web db app]
server 'sw-webapp-e.stanford.edu', user: 'blacklight', roles: %w[web db app]

server 'sw-webapp-bot-a.stanford.edu', user: 'blacklight', roles: %w[web db app]
server 'sw-webapp-bot-b.stanford.edu', user: 'blacklight', roles: %w[web db app]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

after 'deploy:updated', 'newrelic:notice_deployment'
