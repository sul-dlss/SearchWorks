# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
require 'fixtures/marc_records/marc_856_fixtures'
require 'fixtures/marc_records/marc_metadata_fixtures'
require 'fixtures/mods_records/mods_fixtures'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {timeout: 60})
end
Capybara.javascript_driver = :poltergeist

Capybara.default_max_wait_time = ENV["CI"] ? 30 : 10

if ENV["COVERAGE"] or ENV["CI"]
  require 'simplecov'
  require 'coveralls' if ENV["CI"]

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter if ENV["CI"]
  SimpleCov.start do
    add_filter "/spec/"
  end
end


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.include Capybara::DSL

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def total_results
  expect(page).to have_selector 'h2', text: number_pattern
  page.find("h2", text: number_pattern).text.gsub(/\D+/, '').to_i
end

def results_all_on_page ids
  ids.all? do |id|
    result_on_page id
  end
end

def result_on_page id
  !all_docs_on_page.index(id).nil?
end

def document_index id
  all_docs_on_page.index(id)
end

def all_docs_on_page
  page.all(:xpath, "//form[@data-doc-id]").map{|e| e["data-doc-id"]}
end

def facet_index(options)
  all_facets_by_name(options[:facet_name]).index(options[:value])
end

def all_facets_by_name(facet_name)
  page.all("##{facet_name} a.facet_select").map(&:text)
end

def number_pattern
  /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/
end
