set :deploy_to, "/opt/app/#{fetch(:user)}/#{fetch(:application)}"
set :deploy_host, 'sw-webapp'
set :bundle_without, %w(sqlite development test).join(' ')

user_server_extensions = %w(a b c d e)
bot_server_extensions = %w(a b)

user_server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}-#{extension}.stanford.edu",
         user: fetch(:user),
         roles: %w(web db app)
end

bot_server_extensions.each do |extension|
  server "#{fetch(:deploy_host)}-bot-#{extension}.stanford.edu",
         user: fetch(:user),
         roles: %w(web db app)
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, "production"
