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
    get '/all', to: redirect { |path_params, req|
      doi = DoiQueryConstraint.extract_doi(req.params[:q])
      Settings.quick_search.doi_loaded_link + CGI.escape(DoiQueryConstraint.doi_regex.match(doi)[1])
    }
  end

  constraints(lambda { |request| request.params[:q].blank? || request.params[:q].scrub.blank? }) do
    get '/' => 'pages#home'
    get '/all' => 'pages#home', as: 'homepage'
  end
  constraints(lambda { |request| request.params[:q]&.scrub&.present? }) do
    get '/all' => 'search#index', as: 'search'
  end
  root to: 'search#index'
  get '/all/opensearch' => 'opensearch#opensearch', as: 'opensearch', :defaults => { :format => 'xml' }
  get '/all/:endpoint' => 'search#show'
end
