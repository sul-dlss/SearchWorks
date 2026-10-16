# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task(:default).clear
task default: [:ci]

desc "Execute the test build that runs in CI"
task ci: ['rubocop', 'environment', 'test:prepare'] do
  ENV['environment'] = 'test'

  Rake::Task["db:migrate"].invoke

  with_solr do
    Rake::Task["searchworks:fixtures"].invoke
    Rake::Task["spec"].invoke
  end
end
