# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'selenium-webdriver'
require 'fixtures/marc_records/marc_856_fixtures'
require 'fixtures/marc_records/marc_metadata_fixtures'
require 'fixtures/mods_records/mods_fixtures'

Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    opts.args << '--no-sandbox'
    opts.args << '--window-size=1000,700'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.register_driver :mobile_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    opts.args << '--no-sandbox'
    opts.args << '--window-size=700,700'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.register_driver :tablet_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    opts.args << '--no-sandbox'
    opts.args << '--window-size=800,700'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_max_wait_time = ENV["CI"] ? 30 : 10


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Capybara::DSL

  config.before(:example, responsive: true) do |example|
    page_width = example.metadata[:page_width].to_i
    driver = if page_width < 767
               :mobile_headless
             elsif page_width < 980
               :tablet_headless
             else
               raise ArgumentError, "Browsers over 980px wide don't need to use the responsive test mode"
             end

    Capybara.javascript_driver = driver
    Capybara.current_driver = driver
  end

  config.after(:example, responsive: true) do
    Capybara.javascript_driver = :headless_chrome
    Capybara.current_driver = :headless_chrome
  end

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
  config.use_transactional_fixtures = true

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
  page.all(:xpath, "//form[@data-doc-id]").map { |e| e["data-doc-id"] }
end

def facet_index(options)
  all_facets_by_name(options[:facet_name]).index(options[:value])
end

def all_facets_by_name(facet_name)
  page.all("##{facet_name} a.facet-select").map(&:text)
end

def number_pattern
  /[1-9](?:\d{0,2})(?:,\d{3})*(?:\.\d*[1-9])?|0?\.\d*[1-9]|0/
end
