# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'selenium-webdriver'
require 'fixtures/marc_records/marc_856_fixtures'
require 'fixtures/marc_records/marc_metadata_fixtures'
require 'fixtures/mods_records/mods_fixtures'

WebMock.disable_net_connect!(allow_localhost: true, allow: [
  'example.com',
  'host.example.com',
  'embed.stanford.edu',
  'api.newrelic.com',
  'www.worldcat.org',
  'example.com&sfx.response_type=multi_obj_xml',
  'api-ssl.bitly.com',
  'eds-api.ebscohost.com',
  'chromedriver.storage.googleapis.com'
])

Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :headless_chrome do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--disable-gpu'
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
    opts.args << '--no-sandbox'
    opts.args << '--window-size=1000,700'
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
    page.current_window.resize_to(example.metadata[:page_width].to_i, 700)
  end

  config.after(:example, responsive: true) do
    page.current_window.resize_to(1000, 700)
  end

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  # config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/examples.txt'

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join("spec/fixtures")

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

  config.include Warden::Test::Helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include FactoryBot::Syntax::Methods
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
  page.all(:xpath, "//form[@data-doc-id]").pluck("data-doc-id")
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

def article_search_for(query)
  stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  visit articles_path

  within '.search-form' do
    fill_in 'q', with: query
    if Capybara.current_driver == :headless_chrome
      find_by_id('search').click
    else
      click_button 'Search'
    end
  end
end
