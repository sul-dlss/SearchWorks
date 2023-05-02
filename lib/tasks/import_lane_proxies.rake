namespace :proxies do
  desc "Create the Lane medical library proxies"
  task import_lane: [:environment] do
    LaneProxyBuilder.run
  end
end
