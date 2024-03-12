# frozen_string_literal: true

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

# Needed until https://github.com/projectblacklight/blacklight/pull/3094 is merged and backported to 7.x,
# then we can configure in CatalogController
Blacklight::Engine.config.blacklight.default_pagination_options = { theme: 'blacklight', left: 3, right: 0 }
