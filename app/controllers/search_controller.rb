class SearchController < ApplicationController
  allow_browser versions: :modern, block: :handle_outdated_browser

  rescue_from AbstractSearchService::NoResults, HTTP::TimeoutError, with: :handle_failed_search

  def index
    @query = params_q_scrubbed
    @specialist = Specialist.find(@query)
  end

  def show
    service = Service.new(params[:endpoint])

    result = service.search_service.search(params_q_scrubbed)
    @presenter = SearchPresenter.new(service, result, params_q_scrubbed)
  end

  # JSON API for Searchworks' mini-bento
  def lib_guides
    service = Service.new('lib_guides')

    result = service.search_service.search(params_q_scrubbed)
    @presenter = SearchPresenter.new(service, result, params_q_scrubbed)
  end

  private

  def handle_failed_search
    @service = Service.new(params[:endpoint])

    render 'failed_search'
  end

  def handle_outdated_browser
    return if Rack::Attack.configuration.safelisted?(request)

    render file: Rails.public_path.join('406-unsupported-browser.html'), layout: false, status: :not_acceptable
  end

  def params_q_scrubbed
    params[:q]&.scrub
  end
end
