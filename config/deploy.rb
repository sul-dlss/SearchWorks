set :application, 'SearchWorks'
set :repo_url, 'https://github.com/sul-dlss/SearchWorks.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :user, 'blacklight'
set :home_directory, "/home/#{fetch(:user)}"

set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/blacklight.yml config/honeybadger.yml config/secrets.yml config/schedule.rb public/robots.txt}

# Default value for linked_dirs is []
set :linked_dirs, %w{config/settings log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
