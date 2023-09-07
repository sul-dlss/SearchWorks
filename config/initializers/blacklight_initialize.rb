BlacklightDynamicSitemap::Engine.config.last_modified_field = 'last_updated'

if Settings.dynamic_sitemap_solr_endpoint == 'export'
  BlacklightDynamicSitemap::Engine.config.solr_endpoint = Settings.dynamic_sitemap_solr_endpoint
  BlacklightDynamicSitemap::Engine.config.modify_show_params = lambda do |id, _default_params|
    {
      sort: 'id asc',
      q: "{!prefix f=hashed_id_ssi v=#{id}}",
      fl: 'id, last_updated'
    }
  end
end
