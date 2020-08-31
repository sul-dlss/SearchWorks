Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  class DoiQueryConstraint
    def self.doi_regex
      /^(?:(?:doi:?\s*|(?:http:\/\/)?(?:dx\.)?(?:doi\.org)?\/))?(10(?:\.\d+){1,2}\/\S+)$/i
    end

    def self.extract_doi(query)
      query.scrub.strip.squish
    end

    def initialize; end

    def matches?(request)
      return false unless request.params[:q]

      doi = DoiQueryConstraint.extract_doi(request.params[:q])
      DoiQueryConstraint.doi_regex.match(doi)
    end
  end

  constraints(DoiQueryConstraint.new) do
    get '/', to: redirect { |path_params, req|
      doi = DoiQueryConstraint.extract_doi(req.params[:q])
      Settings.quick_search.doi_loaded_link + CGI.escape(DoiQueryConstraint.doi_regex.match(doi)[1])
    }
  end

  constraints(lambda { |request| request.params[:q].blank? || request.params[:q].scrub.blank? }) do
    get '/' => 'pages#home'
  end

  root to: 'search#index'
  get '/' => 'search#index', as: 'quick_search'
  get 'opensearch' => 'opensearch#opensearch', :defaults => { :format => 'xml' }
  get 'xhr_search/:endpoint' => 'search#xhr_search', as: 'xhr_search', defaults: { :format => 'html' }
end
