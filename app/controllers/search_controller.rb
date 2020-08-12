class SearchController < ApplicationController
  def params_q_scrubbed
    params[:q]&.scrub
  end
  helper_method :params_q_scrubbed

  def index
    @search_form_placeholder = I18n.t "defaults_search.search_form_placeholder"
    @page_title = I18n.t "defaults_search.display_name"
    @module_callout = I18n.t "defaults_search.module_callout"

    render '/pages/home' and return unless search_in_params?

    @query = params_q_scrubbed
    @search_in_params = true
    @searches = SearchService.new.all(@query)
    @found_types = @searches.select { |key, searcher| searcher && !searcher.results.blank? }.keys
  end

  # The following searches for individual sections of the page.
  # This allows us to do client-side requests in cases where the original server-side
  # request times out or otherwise fails.
  def xhr_search
    endpoint = params[:endpoint]

    @query = params_q_scrubbed

    searcher = SearchService.new.one(endpoint, @query)

    respond_to do |format|
      format.html {
        render :json => { endpoint => render_to_string(
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

  private

  def search_in_params?
    params_q_scrubbed.present?
  end
  helper_method :search_in_params?

end
