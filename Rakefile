# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

def system_with_error_handling(*args)
  Open3.popen3(*args) do |_stdin, stdout, stderr, thread|
    puts stdout.read
    raise "Unable to run #{args.inspect}: #{stderr.read}" unless thread.value.success?
  end
end

def wait_for(url)
  30.times do
    begin
      Faraday.get(url.to_s)
      puts "Success!"
      return
    rescue Faraday::ConnectionFailed
      print "."
    end
    sleep 1
  end
end

def with_solr(&block)
  if system('docker compose version')
    begin
      puts "Starting Solr"
      system_with_error_handling "docker compose up -d solr"
      url = URI(Blacklight.default_index.connection.options[:url].delete_suffix('blacklight-core'))
      puts "Waiting for Solr on #{url}..."
      wait_for(url)

      yield
    ensure
      puts "Stopping Solr"
      system_with_error_handling "docker compose stop solr"
    end
  else
    require 'solr_wrapper'

    SolrWrapper.wrap do |solr|
      Rake::Task['searchworks:copy_solr_dependencies'].invoke

      solr.with_collection(name: 'blacklight-core', &block)
    end
  end
end

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
