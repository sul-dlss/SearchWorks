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
  def search_all_in_threads(primary_searcher = 'defaults')
    benchmark "%s server ALL" % CGI.escape(query.to_str) do
      search_threads = []
      @found_types = [] # add the types that are found to a navigation bar

      if primary_searcher == 'defaults'
        searchers = Settings.ENABLED_SEARCHERS
      else
        searcher_config = searcher_config(primary_searcher)
        if searcher_config and searcher_config.has_key? 'with_paging'
          searchers = searcher_config['with_paging']['searchers']
        else
          searchers = [primary_searcher]
        end
      end

      # Constantize all searchers before creating searcher threads
      # Excluding this line causes threads to hang indefinitely as of Rails 5
      Settings.ENABLED_SEARCHERS.each do |searcher_name|
        "QuickSearch::#{searcher_name.camelize}Searcher".constantize
      end

      searchers.shuffle.each do |search_method|
        search_threads << Thread.new(search_method) do |sm|
          benchmark "%s server #{sm}" % CGI.escape(query.to_str) do
            begin
              klass = "QuickSearch::#{sm.camelize}Searcher".constantize

              http_client = HTTPClient.new
              update_searcher_timeout(http_client, sm)
              # FIXME: Probably want to set paging and offset somewhere else.
              # searcher = klass.new(http_client, params_q_scrubbed, QuickSearch::Engine::APP_CONFIG['per_page'], 0, 1, on_campus?(request.remote_ip))
              if sm == primary_searcher
                if searcher_config.has_key? 'with_paging'
                  per_page = searcher_config['with_paging']['per_page']
                else
                  per_page = 10
                end
                searcher = klass.new(http_client, query, per_page, offset(page, per_page), page, on_campus?(ip), scope)
              else
                searcher = klass.new(http_client, query, QuickSearch::Engine::APP_CONFIG['per_page'], 0, 1, on_campus?(ip), scope)
              end
              searcher.search
              unless searcher.is_a? StandardError or searcher.results.blank?
                @found_types.push(sm)
              end
              instance_variable_set "@#{sm}", searcher
            rescue StandardError => e
              # logger.info e

              # Wrap e in a SearcherError, so that the searcher object is
              # available for retrieval.
              searcher_error = SearcherError.new(e, searcher)
              logger.info "FAILED SEARCH: #{sm} | #{params_q_scrubbed}"
              instance_variable_set :"@#{sm.to_s}", searcher_error
            end
          end
        end
      end
      search_threads.each {|t| t.join}
    end
  end


  def page
    if page_in_params?
      page = params[:page].to_i
    else
      page = 1
    end
    page
  end

  def offset(page, per_page)
    (page * per_page) - per_page
  end

  def query
    extracted_query(params_q_scrubbed)
  end

  def scope
    extracted_scope(params_q_scrubbed)
  end

  def update_searcher_timeout(client, search_method, xhr=false)
    timeout_type = xhr ? 'xhr_http_timeout' : 'http_timeout'
    timeout = QuickSearch::Engine::APP_CONFIG[timeout_type]

    if QuickSearch::Engine::APP_CONFIG.has_key? search_method and QuickSearch::Engine::APP_CONFIG[search_method].has_key? timeout_type
        timeout = QuickSearch::Engine::APP_CONFIG[search_method][timeout_type]
    end

    client.receive_timeout = timeout
    client.send_timeout = timeout
    client.connect_timeout = timeout
  end

  # include QuickSearch::DoiTrap

  def doi_trap
    unless params_q_scrubbed.nil?
      if is_a_doi?(doi_query)
        Event.create(category: 'doi-trap', query: doi_query, action: 'click')
        redirect_to doi_loaded_link
        # Alternately insert a loaded link into the results interface
        # @doi_loaded_link = loaded_link
        # @doi_callout = "Searching for a DOI? Try this: "
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
     QuickSearch::Engine::APP_CONFIG['doi_loaded_link'] + CGI.escape(doi_regex.match(doi_query)[1])
  end

  def doi_query
    query = params_q_scrubbed
    query.strip!
    query.squish!
    query
  end

  # include QuickSearch::QueryParser
  def extracted_query(unfiltered_query)
    @unfiltered_query = unfiltered_query
    if extracted_query_and_scope
      query = extracted_query_and_scope[:query]
    else
      query = unfiltered_query
    end
    query
  end

  def extracted_scope(unfiltered_query)
    @unfiltered_query = unfiltered_query
    if extracted_query_and_scope
      scope = extracted_query_and_scope[:value]
    else
      scope = ''
    end
  end

  def extracted_query_and_scope
    if regex_matches = prefix_scope_multi_regex.match(@unfiltered_query)
      regex_matches
    elsif regex_matches = suffix_scope_multi_regex.match(@unfiltered_query)
      regex_matches
    elsif regex_matches = prefix_scope_regex.match(@unfiltered_query)
      regex_matches
    elsif regex_matches = suffix_scope_regex.match(@unfiltered_query)
      regex_matches
    end
    regex_matches
  end

  def prefix_scope_regex
    /^(?<option>scope):(?<value>\S+)\s?(?<query>.*)$/
  end

  def prefix_scope_multi_regex
    /^(?<option>scope):\((?<value>.*?)\)\s?(?<query>.*)$/
  end

  def suffix_scope_regex
    /(?<query>.*)\s(?<option>scope):(?<value>\S+)/
  end

  def suffix_scope_multi_regex
    /^(?<query>.*)\s(?<option>scope):\((?<value>.*)\)$/
  end

  # include QuickSearch::EncodeUtf8
  def params_q_scrubbed
    unless params[:q].nil?
      params[:q].scrub
    end
  end
  # include QuickSearch::QueryFilter
  #include QuickSearch::SearcherConfig
  def searcher_config(*args)
    nil
  end

  BenchmarkLogger = ActiveSupport::Logger.new(Rails.root.join('log/benchmark.log'))
  BenchmarkLogger.formatter = Logger::Formatter.new

  before_action :doi_trap

  def index
    loaded_searches
    @common_searches = common_searches
    http_search
  end

  # TODO: throw error if required files not in place
  def single_searcher
    searcher_name = params[:searcher_name]

    searcher_cfg = searcher_config(searcher_name)
    if searcher_cfg and searcher_cfg.has_key? 'loaded_searches'
      additional_services = Array.new(searcher_cfg['loaded_searches'])
    else
      additional_services = []
    end
    loaded_searches(additional_services)

    @common_searches = []
    if searcher_cfg and searcher_cfg.has_key? 'common_searches'
      @common_searches = searcher_cfg['common_searches']
    end

    #TODO: maybe a default template for single-searcher searches?
    http_search(searcher_name, "search/#{searcher_name}_search")
  end

  # The following searches for individual sections of the page.
  # This allows us to do client-side requests in cases where the original server-side
  # request times out or otherwise fails.
  def xhr_search
    endpoint = params[:endpoint]

    if params[:template] == 'with_paging'
      template = 'xhr_response_with_paging'
    else
      template = 'xhr_response'
    end

    @query = params_q_scrubbed
    @page = page
    @per_page = per_page(endpoint)
    @offset = offset(@page,@per_page)

    http_client = HTTPClient.new
    update_searcher_timeout(http_client, endpoint, true)

    benchmark "%s xhr #{endpoint}" % CGI.escape(@query.to_str) do

      klass = "QuickSearch::#{endpoint.camelize}Searcher".constantize
      searcher = klass.new(http_client,
                           extracted_query(params_q_scrubbed),
                           @per_page,
                           @offset,
                           @page,
                           true, # on campus
                           extracted_scope(params_q_scrubbed))
      searcher.search

      searcher_partials = {}
      searcher_cfg = searcher_config(endpoint)
      unless searcher_cfg.blank?
        services = searcher_cfg['services'].blank? ? [] : searcher_cfg['services']
      else
        services = []
      end
      services << endpoint

      respond_to do |format|

        format.html {
          services.each do |service|
            service_template = render_to_string(
              :partial => "search/#{template}",
              :layout => false,
              :locals => { module_display_name: t("#{endpoint}_search.display_name"),
                           searcher: searcher,
                           search: '',
                           service_name: service
                          })
            searcher_partials[service] = service_template
          end
          render :json => searcher_partials
        }

        format.json {

          # prevents openstruct object from results being nested inside tables
          # See: http://stackoverflow.com/questions/7835047/collecting-hashes-into-openstruct-creates-table-entry
          result_list = []
          searcher.results.each do |result|
            result_list << result.to_h
          end

          render :json => { :endpoint => endpoint,
                            :per_page => @per_page.to_s,
                            :page => @page.to_s,
                            :total => searcher.total,
                            :results => result_list
          }
        }
      end
    end
  end

  private

  def http_search(endpoint = 'defaults', page_to_render = :index)
    @ip = request.remote_ip

    @search_form_placeholder = I18n.t "#{endpoint}_search.search_form_placeholder"
    @page_title = I18n.t "#{endpoint}_search.display_name"
    @module_callout = I18n.t "#{endpoint}_search.module_callout"

    if search_in_params?
      @query = params_q_scrubbed
      @search_in_params = true
      search_all_in_threads(endpoint)
      #log_search(@query, page_to_render)
      render page_to_render
    else
      @search_in_params = false
      render '/pages/home'
    end
  end

  def page
    if page_in_params?
      page = params[:page].to_i
    else
      page = 1
    end
    page
  end
  helper_method :page

  def per_page(endpoint)
    searcher_cfg = searcher_config(endpoint)
    if params[:per_page]
      per_page = params[:per_page].to_i
    elsif params[:template] == 'with_paging'
      if searcher_cfg and searcher_cfg.has_key? 'with_paging'
        per_page = searcher_cfg['with_paging']['per_page']
      else
        per_page = 10
      end
    else
      per_page = Settings.quick_search.per_page
    end

    if per_page > Settings.quick_search.max_per_page
      per_page = Settings.quick_search.max_per_page
    end

    per_page
  end

  def offset(page, per_page)
    (page * per_page) - per_page
  end

  def page_in_params?
    params[:page] && !params[:page].blank?
  end

  def search_in_params?
    params_q_scrubbed && !params_q_scrubbed.blank?
  end
  helper_method :search_in_params?

  def common_searches
    Settings.quick_search.common_searches
  end

  def loaded_searches(additional_services=[])
    @search_services_for_display = []
    @extracted_query = extracted_query(params_q_scrubbed)
    search_services = additional_services + Array.new(Settings.quick_search.loaded_searches)

    search_services.each do |search_service|
      if search_in_params?
        @search_services_for_display << {'name' => search_service['name'], 'link'=> search_service['query'] + extracted_query(params_q_scrubbed)}
      else
        @search_services_for_display << {'name' => search_service['name'], 'link'=> search_service['landing_page']}
      end
    end
  end

  def benchmark(message)
    result = nil
    ms = Benchmark.ms { result = yield }
    BenchmarkLogger.info '%s (%.1fms)' % [ message, ms ]
    result
  end
end
