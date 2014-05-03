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
end
