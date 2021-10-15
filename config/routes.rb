Rails.application.routes.draw do
  root to: "catalog#index"

  get "view/:id/librarian_view" => "catalog#librarian_view", :as => :librarian_view
  get "view/:id/stackmap" => "catalog#stackmap", :as => :stackmap

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/' if Settings.GENERATE_SITEMAP

  mount BlacklightAdvancedSearch::Engine => '/'
  mount MockExhibitsFinderEndpoint.new, at: '/exhibit_finder' if Rails.env.test?

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resources :barcode, only: :show

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog' do
    concerns :exportable
  end

  constraints(id: /[^\/]+/) do # EDS identifier rules (e.g., db__acid) where acid has all sorts of different punctuation
    resources :bookmarks, path: :selections do
      concerns :exportable

      collection do
        delete 'clear'
      end

      collection do
        resources :article_selections, path: :articles do
          concerns :exportable
        end
      end
    end
  end

  resources :collection_members, only: :show

  Blacklight::Marc.add_routes(self)
  devise_for :users, skip: [:registrations, :passwords, :sessions]
  devise_scope :user do
    get 'webauth/login' => 'login#login', as: :new_user_session
    match 'webauth/logout' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  get "databases" => "catalog#index", :defaults => { f: { format_main_ssim: ["Database"] } }

  get 'govdocs' => 'catalog#index', defaults: { f: { genre_ssim: ['Government document'] } }, as: :govdocs

  resources :selected_databases, only: :index

  resources :hours, only: :show

  resource :feedback_form, path: "feedback", only: [:new, :create]

  resource :quick_reports, only: [:create]

  resources :embed, only: :show

  resources :lib_guides, only: :index

  resources :browse, only: :index

  get "browse/nearby" => "browse#nearby"

  get "feedback" => "feedback_forms#new"
  get "backend_lookup" => "catalog#backend_lookup", defaults: { format: :json }, as: :catalog_backend_lookup
  get 'articles/backend_lookup' => 'articles#backend_lookup', defaults: { format: :json }, as: :articles_backend_lookup

  get 'view/:id/availability' => 'catalog#availability', defaults: { format: :json }

  resources :preview, only: :show

  resources :availability, only: :index

  resources :recent_selections, only: :index

  resources :course_reserves, only: :index, path: "reserves"

  constraints(id: /[^\/]+/) do # EDS identifier rules (e.g., db__acid) where acid has all sorts of different punctuation
    resources :articles, only: %i[index show] do
      concerns :exportable
    end

    get 'articles/:id/ris' => 'articles#show', as: :articles_ris, constraints: ->(req) { req.format = :ris }

    post 'articles/:id/track' => 'articles#track', as: :track_articles
    get 'articles/:id/:type/fulltext' => 'articles#fulltext_link', as: :article_fulltext_link, constraints: { type: /[-\w]+/ }
  end

  resource :sfx_data, only: :show

  # Vanity URL used in development office mailings
  get '/funds/:fund', to: redirect { |path_params, _req| "/?f[fund_facet][]=#{path_params[:fund].upcase}" }
end
