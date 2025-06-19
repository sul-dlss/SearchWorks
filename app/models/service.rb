# frozen_string_literal: true

# Does an HTTP request to the configured service endpoint.
class Service
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def i18n_key
    @i18n_key ||= "#{@name}_search"
  end

  def settings
    case @name
    when 'lib_guides'
      Settings.libguides
    when 'library_website_api'
      Settings.library_website
    else
      Settings.public_send(@name)
    end
  end

  def search_service
    "#{name.camelize}SearchService".constantize.new
  end

  def see_all_url_template
    settings.query_url
  end
end
