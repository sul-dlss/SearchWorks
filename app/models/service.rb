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

  def search_service_class
    "#{name.camelize}SearchService".constantize
  end

  # @param [String] query_text
  # @raises [HTTP::TimeoutError] if a timeout occurs during the search
  # @returns [Array<Hash>, NilClass] an array of search results or nil if there was an error
  def query(query_text, timeout: 30)
    http = HTTP.timeout(timeout).headers(user_agent: "#{HTTP::Request::USER_AGENT} (#{Settings.user_agent})")

    search_service_class.new(http: http).search(query_text)
  end

  def see_all_url_template
    settings.query_url
  end
end
