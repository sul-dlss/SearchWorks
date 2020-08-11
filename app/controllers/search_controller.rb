class SearchController < ApplicationController
  class SearcherError < StandardError
    attr_reader :searcher

    def initialize(e=nil, searcher)
      super e
      @searcher = searcher
      set_backtrace e.backtrace if e
    end
  end

  # include QuickSearch::SearcherConcern
  def search_all_in_threads(query, primary_searcher = 'defaults')
    @searches = Settings.ENABLED_SEARCHERS.each_with_object({}) do |hash, searcher|
      # Constantize all searchers before creating searcher threads
      # Excluding this line causes threads to hang indefinitely as of Rails 5
      "QuickSearch::#{searcher_name.camelize}Searcher".constantize

      hash[searcher] = nil
    end

    benchmark "%s server ALL" % CGI.escape(query.to_str) do
      search_threads = @searches.keys.shuffle.map do |search_method|
        Thread.new(search_method) do |sm|
          benchmark "%s server #{sm}" % CGI.escape(query.to_str) do
            begin
              klass = "QuickSearch::#{sm.camelize}Searcher".constantize

              http_client = HTTPClient.new
              update_searcher_timeout(http_client, sm)
              searcher = klass.new(http_client, query)
              searcher.search
              @searches[search_method] = searcher
            rescue StandardError => e
              logger.info "FAILED SEARCH: #{sm} | #{params_q_scrubbed} | #{e}"
            end
          end
        end
      end
      search_threads.each {|t| t.join}
    end

    @found_types = @searchers.select { |searcher| searcher && !searcher.results.blank? }
  end

  def update_searcher_timeout(client, search_method, xhr=false)
    timeout_type = xhr ? 'xhr_http_timeout' : 'http_timeout'
    timeout = Settings.quick_search[timeout_type]

    client.receive_timeout = timeout
    client.send_timeout = timeout
    client.connect_timeout = timeout
  end

  # include QuickSearch::DoiTrap

  def doi_trap
    unless params_q_scrubbed.nil?
      if is_a_doi?(doi_query)
        redirect_to doi_loaded_link
      end
    end
  end

  def is_a_doi?(query)
    if doi_regex.match(query)
      true
    else
      false
    end
  end

  def doi_regex
    /^(?:(?:doi:?\s*|(?:http:\/\/)?(?:dx\.)?(?:doi\.org)?\/))?(10(?:\.\d+){1,2}\/\S+)$/i
  end

  def doi_loaded_link
     Settings.quick_search.doi_loaded_link + CGI.escape(doi_regex.match(doi_query)[1])
  end

  def doi_query
    query = params_q_scrubbed
    query.strip!
    query.squish!
    query
  end

  def params_q_scrubbed
    params[:q]&.scrub
  end

  BenchmarkLogger = ActiveSupport::Logger.new(Rails.root.join('log/benchmark.log'))
  BenchmarkLogger.formatter = Logger::Formatter.new

  before_action :doi_trap

  def index
    http_search
  end

  # TODO: throw error if required files not in place
  def single_searcher
    searcher_name = params[:searcher_name]


    #TODO: maybe a default template for single-searcher searches?
    http_search(searcher_name, "search/#{searcher_name}_search")
  end

  # The following searches for individual sections of the page.
  # This allows us to do client-side requests in cases where the original server-side
  # request times out or otherwise fails.
  def xhr_search
    endpoint = params[:endpoint]

    @query = params_q_scrubbed

    http_client = HTTPClient.new
    update_searcher_timeout(http_client, endpoint, true)

    benchmark "%s xhr #{endpoint}" % CGI.escape(@query.to_str) do

      klass = "QuickSearch::#{endpoint.camelize}Searcher".constantize
      searcher = klass.new(http_client, @query)
      searcher.search

      respond_to do |format|
        format.html {
          render :json => { service => render_to_string(
            :partial => "search/xhr_response",
            :layout => false,
            :locals => { module_display_name: t("#{endpoint}_search.display_name"),
                         searcher: searcher,
                         search: '',
                         service_name: endpoint
                        })}
        }

        format.json {

          # prevents openstruct object from results being nested inside tables
          # See: http://stackoverflow.com/questions/7835047/collecting-hashes-into-openstruct-creates-table-entry
          result_list = []
          searcher.results.each do |result|
            result_list << result.to_h
          end

          render :json => { :endpoint => endpoint,
                            :total => searcher.total,
                            :results => result_list
          }
        }
      end
    end
  end

  private

  def http_search(endpoint = 'defaults', page_to_render = :index)
    @search_form_placeholder = I18n.t "#{endpoint}_search.search_form_placeholder"
    @page_title = I18n.t "#{endpoint}_search.display_name"
    @module_callout = I18n.t "#{endpoint}_search.module_callout"

    if search_in_params?
      @query = params_q_scrubbed
      @search_in_params = true
      search_all_in_threads(@query, endpoint)
      #log_search(@query, page_to_render)
      render page_to_render
    else
      @search_in_params = false
      render '/pages/home'
    end
  end

  def search_in_params?
    params_q_scrubbed.present?
  end
  helper_method :search_in_params?

  def benchmark(message)
    result = nil
    ms = Benchmark.ms { result = yield }
    BenchmarkLogger.info '%s (%.1fms)' % [ message, ms ]
    result
  end
end
