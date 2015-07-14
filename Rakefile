# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
task default: [:ci]
require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.6.0.zip"
begin
  require 'jettywrapper'
rescue LoadError => e
  # should only get here when deployed as prod - in which case don't need those rake tasks
end

desc "Execute the test build that runs on travis"
task :ci => [:environment] do
  if Rails.env.test?
    Rake::Task["db:migrate"].invoke
    Rake::Task["searchworks:download_and_unzip_jetty"].invoke
    Rake::Task["searchworks:copy_solr_configs"].invoke
    Jettywrapper.wrap(Jettywrapper.load_config) do
      Rake::Task["searchworks:fixtures"].invoke
      Rake::Task["searchworks:spec:without-data-integration"].invoke
    end
  else
    system("rake ci RAILS_ENV=test")
  end
end
desc "Execute the test build that runs on jenkins"
task :jenkins => [:environment] do
  if Rails.env.test?
    Rake::Task["searchworks:spec:data-integration"].invoke
  else
    system("rake jenkins RAILS_ENV=test")
  end
end
