# enables caching for Open Annotation jsonld context files
require 'restclient/components'
require 'rack/cache'
RestClient.enable Rack::Cache,
  metastore: "file:#{Rails.root}/tmp/rack-cache/meta",
  entitystore: "file:#{Rails.root}/tmp/rack-cache/body",
  default_ttl:  86400, # when to recheck, in seconds (daily = 60 x 60 x 24)
  verbose: false