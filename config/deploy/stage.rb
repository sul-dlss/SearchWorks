set :deploy_host, 'sw-webapp-stage'
set :bundle_without, %w{sqlite development test}.join(' ')
set :deploy_to, "/opt/app/#{fetch(:user)}/#{fetch(:application)}"

server_extensions = ['a', 'b', 'c']

server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}-#{extension}.stanford.edu", user: fetch(:user), roles: %w{web db app}
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"
