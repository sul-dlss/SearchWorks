require 'fixtures_indexer'
require 'jettywrapper'
namespace :searchworks do
  desc "Run SearchWorks local installation steps"
  task :install => [:environment] do
    Rake::Task["db:migrate"].invoke
    unless File.exists?("#{Rails.root}/jetty")
      puts "Downloading jetty\n"
      Rake::Task["jetty:download"].invoke
      puts "Unzipping jetty\n"
      Rake::Task["jetty:unzip"].invoke
    end
    puts "Indexing fixtures\n"
    Jettywrapper.wrap(Jettywrapper.load_config) do
      Rake::Task["searchworks:fixtures"].invoke
    end
  end
  desc "Index test fixtures"
  task :fixtures do
    FixturesIndexer.run
  end
  namespace :spec do
    begin
      require 'rspec/core/rake_task'
      desc "spec task that runs only data-integration tests (run on Jenkins against production data)"
      RSpec::Core::RakeTask.new("data-integration") do |t|
        t.rspec_opts = "--tag data-integration"
      end
      desc "spec task that ignores data-integration tests (run during local development/travis on local data)"
      RSpec::Core::RakeTask.new("without-data-integration") do |t|
        t.rspec_opts =  "--tag ~data-integration"
      end
      task 'spec:all' => 'test:prepare'
    rescue LoadError => e
      desc 'rspec not installed'
      task 'data-integration' do
        abort 'rspec not installed'
      end
      desc 'rspec not installed'
      task 'without-data-integration' do
        abort 'rspec not installed'
      end
    end
  end
end
