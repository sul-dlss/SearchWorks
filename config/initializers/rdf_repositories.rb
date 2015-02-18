def configure_repositories
  ActiveTriples::Repositories.clear_repositories!
  ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
end

# Not sure why configure_repositories is called twice in this way. Code modified from Oregon Digital project.
configure_repositories
Rails.application.config.to_prepare do
  configure_repositories
end