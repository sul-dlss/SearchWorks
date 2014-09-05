set :deploy_host, ask("Server", 'e.g. hostname with no ".stanford.edu" or server node designator')
set :bundle_without, %w{sqlite development test}.join(' ')

server_extensions = ['a', 'b', 'c', 'd', 'e']

server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}-#{extension}.stanford.edu", user: fetch(:user), roles: %w{web db app}
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"
