# frozen_string_literal: true

require 'oembed'
class PURLEmbed
  delegate :html, to: :resource

  def initialize(druid)
    @druid = druid
    set_url_scheme
  end

  private

  def resource
    @resource ||= provider.get("#{Settings.PURL_EMBED_RESOURCE}#{@druid}")
  end

  def provider
    @provider ||= OEmbed::Provider.new("#{Settings.PURL_EMBED_PROVIDER}.{format}?hide_title=true", :json)
  end

  def set_url_scheme
    provider << Settings.PURL_EMBED_URL_SCHEME
  end
end
