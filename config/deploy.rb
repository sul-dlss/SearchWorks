set :application, 'SearchWorks'
set :repo_url, 'https://github.com/sul-dlss/SearchWorks.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :deploy_to, '/opt/app/blacklight/SearchWorks'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/blacklight.yml config/honeybadger.yml config/newrelic.yml config/secrets.yml public/robots.txt}

# Default value for linked_dirs is []
set :linked_dirs, %w{config/settings log tmp/pids tmp/cache tmp/sockets tmp/faraday_eds_cache vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# We want Honeybadger to report deployments to our Capistrano stage names (e.g., dev, stage, prod)
set :honeybadger_env, fetch(:stage)

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
