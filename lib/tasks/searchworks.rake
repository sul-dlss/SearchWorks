require 'fixtures_indexer'

namespace :searchworks do
  desc "Run SearchWorks local installation steps"
  task install: [:environment] do
    Rake::Task["db:migrate"].invoke
    SolrWrapper.wrap do |solr|
      Rake::Task['searchworks:copy_solr_dependencies'].invoke
      solr.with_collection(name: 'blacklight-core') do
        Rake::Task['searchworks:fixtures'].invoke
      end
    end
  end

  desc "Index test fixtures"
  task fixtures: :environment do
    FixturesIndexer.run
  end

  desc 'Copy necessary solr dependencies to local solr instance'
  task copy_solr_dependencies: [:environment] do
    copy_task = lambda do
      FileUtils.cp(
        Rails.root.join('config', 'solr_configs', 'CJKFilterUtils-v3.0.jar'),
        File.join(SolrWrapper.instance.instance_dir, 'contrib')
      )
    end

    begin
      copy_task.call
    rescue Errno::ENOENT # solr instance_dir does not exist
      SolrWrapper.wrap do
        copy_task.call
      end
    end
  end

  desc "Prune old search data from the database"
  task :prune_old_search_data, [:days_old] => [:environment] do |t, args|
    chunk = 20000
    raise ArgumentError.new('days_old is expected to be greater than 0') if args[:days_old].to_i <= 0

    total = Search.where("updated_at < :date", { date: args[:days_old].to_i.days.ago }).count
    total = total - (total % chunk) if (total % chunk) != 0
    i = 0
    while i < total
      # might want to add a .where("user_id = NULL") when we have authentication hooked up.
      Search.delete(Search.order("updated_at").limit(chunk).pluck(:id))
      i += chunk
      sleep(10)
    end
  end

  desc "Prune old guest users from the database"
  task :prune_old_guest_user_data, [:months_old] => [:environment] do |t, args|
    old_bookmarkless_guest_users_ids = User.includes(:bookmarks)
                                           .where(guest: true)
                                           .where(bookmarks: { user_id: nil })
                                           .where("users.updated_at < :date", { date: args[:months_old].to_i.months.ago })
                                           .pluck(:id)

    User.delete(old_bookmarkless_guest_users_ids)
  end

  desc "Clear Rack::Attack cache"
  task clear_rack_attack_cache: [:environment] do
    if Settings.THROTTLE_TRAFFIC
      # This functionality will be available as Rack::Attack.reset! but as of 6.2.2 this is not released
      store = Rack::Attack.cache.store
      if store.respond_to?(:delete_matched)
        store.delete_matched("#{Rack::Attack.cache.prefix}*")
      else
        puts "Error Clearing Rack::Attack cache. Store #{store.class.name} does not respond to #delete_matched"
      end
    end
  end

  def eds_cache
    cache_dir = File.join(Settings.EDS_CACHE_DIR, 'faraday_eds_cache')
    return ActiveSupport::Cache::FileStore.new(cache_dir) if File.directory?(cache_dir)

    nil
  end

  desc "Prune expired files in EDS cache"
  task prune_eds_cache: [:environment] do |t, args|
    if eds_cache
      puts "Cleaning cache in #{eds_cache.cache_path}"
      eds_cache.cleanup
    end
  end
  desc "Clear all files in EDS cache"
  task clear_eds_cache: [:environment] do |t, args|
    if eds_cache
      puts "Clearing cache in #{eds_cache.cache_path}"
      eds_cache.clear
    end
  end
end
