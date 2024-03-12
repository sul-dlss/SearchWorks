# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task(:default).clear
task default: [:ci]

desc "Execute the test build that runs in CI"
task ci: %i[rubocop environment] do
  require 'solr_wrapper'

  ENV['environment'] = 'test'

  Rake::Task["db:migrate"].invoke

  SolrWrapper.wrap do |solr|
    Rake::Task['searchworks:copy_solr_dependencies'].invoke

    solr.with_collection(name: 'blacklight-core') do
      Rake::Task["searchworks:fixtures"].invoke
      Rake::Task["spec"].invoke
    end
  end
end
