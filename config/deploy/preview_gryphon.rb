set :bundle_without, %w(sqlite development test).join(' ')
set :deploy_to, "/opt/app/#{fetch(:user)}/#{fetch(:application)}"

# Other aliases are sw-gryphon-search, gryphon-search, and searchworks-gryphon-search
server 'sw-webapp-sandbox-c.stanford.edu', user: fetch(:user), roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
