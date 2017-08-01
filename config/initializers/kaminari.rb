Kaminari.configure do |config|
  # FIXME: This should be set per searcher in the main quicksearch config
  config.default_per_page = 20
  config.window = 3
end
