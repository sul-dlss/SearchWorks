require 'fixtures_indexer'
require 'jettywrapper'
namespace :searchworks do
  desc "Run SearchWorks local installation steps"
  task :install => [:environment] do
    Rake::Task["db:migrate"].invoke
    Rake::Task["searchworks:download_and_unzip_jetty"].invoke
    Rake::Task["searchworks:copy_solr_configs"].invoke
    puts "Indexing fixtures\n"
    Jettywrapper.wrap(Jettywrapper.load_config) do
      Rake::Task["searchworks:fixtures"].invoke
    end
  end
  desc "Index test fixtures"
  task :fixtures do
    FixturesIndexer.run
  end
  desc "Download and unzip jetty"
  task :download_and_unzip_jetty do
    unless File.exists?("#{Rails.root}/jetty")
      puts "Downloading jetty"
      Rake::Task["jetty:download"].invoke
      puts "Unzipping jetty"
      Rake::Task["jetty:unzip"].invoke
    end
  end
  desc "Copy solr configs"
  task :copy_solr_configs do
    %w{schema solrconfig}.each do |file|
      cp "#{Rails.root}/config/solr_configs/#{file}.xml", "#{Rails.root}/jetty/solr/blacklight-core/conf/"
    end
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
  desc "Prune old search data from the database"
  task :prune_old_search_data, [:days_old] => [:environment] do |t, args|
    chunk = 20000
    raise ArgumentError.new('days_old is expected to be greater than 0') if args[:days_old].to_i <= 0
    total = Search.where("updated_at < :date", {date: (Date.today - args[:days_old].to_i)}).count
    total = total - (total % chunk) if (total % chunk) != 0
    i = 0
    while i < total
      # might want to add a .where("user_id = NULL") when we have authentication hooked up.
      Search.destroy(Search.order("updated_at").limit(chunk).map(&:id))
      i += chunk
      sleep(10)
    end
  end

  def eds_cache
    cache_dir = File.join(Settings.EDS_CACHE_DIR, 'faraday_eds_cache')
    return ActiveSupport::Cache::FileStore.new(cache_dir) if File.directory?(cache_dir)
    nil
  end

  desc "Prune expired files in EDS cache"
  task :prune_eds_cache => [:environment] do |t, args|
    if eds_cache
      puts "Cleaning cache in #{eds_cache.cache_path}"
      eds_cache.cleanup
    end
  end
  desc "Clear all files in EDS cache"
  task :clear_eds_cache => [:environment] do |t, args|
    if eds_cache
      puts "Clearing cache in #{eds_cache.cache_path}"
      eds_cache.clear
    end
  end
end
