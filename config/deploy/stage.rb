set :rails_env, 'production'

server 'sul-bento-stage-a.stanford.edu', user: 'bento', roles: %w[web db app]
server 'sul-bento-stage-b.stanford.edu', user: 'bento', roles: %w[web app]

set :bundle_without, %w[deployment development test].join(' ')

Capistrano::OneTimeKey.generate_one_time_key!
