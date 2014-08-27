set :keep_releases, 50

set :deploy_host, ask("Server", 'e.g. server.stanford.edu')

set :sub_dir, "redesign"
set :symlinks_directory, "#{fetch(:home_directory)}/SearchWorksSubURIs"
set :symlink_deploy_path, "#{fetch(:symlinks_directory)}/#{fetch(:sub_dir)}"
set :bundle_without, %w{production test}.join(' ')

set :rvm_ruby_version, '2.1.0'

task :symlink_sub_directory_deploy do
  on roles(:app), wait: 1 do
    set :last_release, capture("ls #{releases_path}").split("\n").last
    set :last_release_path, "#{releases_path}/#{fetch(:last_release)}"
    set :public_release_path, "#{fetch(:last_release_path)}/public"
    # Write .htaccess file with RailsBaseURI directive
    execute("echo 'RailsBaseURI /#{fetch(:sub_dir)}' > #{fetch(:public_release_path)}/.htaccess")
    execute("echo 'PassengerRuby /usr/local/rvm/wrappers/ruby-2.1.0-preview2/ruby' >> #{fetch(:public_release_path)}/.htaccess")
    # Remove symlink if it already exists
    execute("rm #{fetch(:symlink_deploy_path)}") if sub_uri_exists? fetch(:symlink_deploy_path)
    # Symlink release's public directory
    execute("ln -s #{fetch(:public_release_path)} #{fetch(:symlink_deploy_path)}")
  end
end

server fetch(:deploy_host), user: fetch(:user), roles: %w{web db app}

Capistrano::OneTimeKey.generate_one_time_key!
# we should try to deploy under production env
# for proper sub-directory asset compilation
set :rails_env, "development"

after  "deploy", "symlink_sub_directory_deploy"

def sub_uri_exists?(path)
  capture("if [[ -d #{path} ]]; then echo -n 'true'; fi").chomp == "true"
end
