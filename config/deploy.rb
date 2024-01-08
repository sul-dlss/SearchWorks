set :application, 'bento'

set :repo_url, 'https://github.com/sul-dlss/sul-bento-app.git'

# Default branch is :master so we need to update to main
if ENV['DEPLOY']
  set :branch, 'main'
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

set :deploy_to, '/opt/app/bento/bento'

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/honeybadger.yml',
  'config/newrelic.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'config/settings'
)

set :honeybadger_env, fetch(:stage)

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'
