require 'oembed'
class PURLEmbed
  def initialize(druid)
    @druid = druid
    set_url_scheme
  end
  def html
    resource.html
  end
  private
  def resource
    @resource ||= provider.get("#{Settings.PURL_EMBED_RESOURCE}#{@druid}")
  end
  def provider
    @provider ||= OEmbed::Provider.new("#{Settings.PURL_EMBED_PROVIDER}.{format}?hide_title=true&hide_metadata=true", :json)
  end
  def set_url_scheme
    provider << Settings.PURL_EMBED_URL_SCHEME
  end
end
