class SearchController < ApplicationController
  allow_browser versions: :modern, block: :handle_outdated_browser

  def index
    @query = params_q_scrubbed
  end

  def show
    endpoint = params[:endpoint]

    @query = params_q_scrubbed

    begin
      @searcher = search_service.one(endpoint)
    rescue AbstractSearchService::NoResults
      @no_answer = true
    end
  end

  private

  def handle_outdated_browser
    return if Rack::Attack.configuration.safelisted?(request)

    render file: Rails.public_path.join('406-unsupported-browser.html'), layout: false, status: :not_acceptable
  end

  def params_q_scrubbed
    params[:q]&.scrub
  end

  def search_service
    SearchService.new(@query)
  end
end
