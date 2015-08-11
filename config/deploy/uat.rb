set :deploy_host, ask("Server", 'e.g. server.stanford.edu')
set :bundle_without, %w{sqlite development test}.join(' ')
set :deploy_to, "/opt/app/#{fetch(:user)}/#{fetch(:application)}"

server fetch(:deploy_host), user: fetch(:user), roles: %w{web db app}

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"
