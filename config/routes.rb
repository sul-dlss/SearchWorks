# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "catalog#index"

  # redirect Symphony-migrated FOLIO HRIDs to their original Symphony URLs
  constraints(id: /a\d+/) do
    get '/view/:id', to: redirect { |path_params, _req| "/view/#{path_params[:id].delete_prefix('a')}" }
  end

  get "view/:id/librarian_view" => "catalog#librarian_view", as: :librarian_view
  get "view/:id/:location/stackmap" => "catalog#stackmap", as: :stackmap
  get "view/:id/availability" => "catalog#availability_modal", :as => :availability_modal

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/' if Settings.GENERATE_SITEMAP

  if Rails.env.test?
    require_relative '../spec/support/rack_apps/mock_exhibits_finder_endpoint'
    mount MockExhibitsFinderEndpoint.new, at: '/exhibit_finder'
  end

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
    get 'facet_results/:id', to: 'catalog#facet_results', as: 'facet_results'
    get 'search_bar'
  end
  get 'advanced', to: 'catalog#advanced_search', as: 'advanced_search'

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]

    member do
      get 'preview'
      get 'bound_with_children/:item_id', to: 'bound_with_children#index', as: 'bound_with_children'
      get 'bound_with_children_modal/:item_id', to: 'bound_with_children#modal', as: 'bound_with_children_modal'
    end
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

  devise_for :users, skip: [:registrations, :passwords, :sessions]
  devise_scope :user do
    get '/sso/login' => 'login#login', as: :new_user_session
    match '/sso/logout' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  resources :databases, only: [:index] do
    collection do
      get 'autocomplete'
    end

    concerns :searchable
    concerns :range_searchable
  end
  post 'databases/:id/track' => 'databases#track', as: :track_databases

  direct :database_search do |subject|
    { controller: '/catalog', action: 'index', f: { db_az_subject: [subject], format_hsim: ['Database'] } }
  end

  direct :govdocs do
    { controller: '/catalog', action: 'index', f: { genre_ssim: ['Government document'] } }
  end

  direct :theses_and_dissertations do
    { controller: '/catalog', action: 'index', f: { genre_ssim: ['Thesis/Dissertation'] } }
  end

  direct :digital_collections do
    { controller: '/catalog', action: 'index', f: { collection_type: ['Digital Collection'] } }
  end

  direct :iiif_items do
    { controller: '/catalog', action: 'index', f: { iiif_resources: ['available'] } }
  end

  direct :collection_members do |document|
    { controller: '/catalog', action: 'index', f: { collection: [document.prefixed_id] } }
  end

  resources :hours, only: :show

  resource :feedback_form, path: "feedback", only: [:new, :create]

  resource :quick_reports, only: [:create]

  resources :browse, only: :index

  get 'catalog/:id/track' => 'catalog#track', as: 'track_browse'
  get 'catalog/:id/track' => 'articles#track', as: 'track_article_selections'

  get "browse/nearby" => "browse#nearby"

  get "feedback" => "feedback_forms#new"

  resources :availability, only: [:show]

  resources :recent_selections, only: :index

  resources :course_reserves, only: :index, path: "reserves"

  direct :course_search do |course|
    { controller: '/catalog', action: 'index', f: { courses_folio_id_ssim: [course.id] } }
  end

  constraints(id: /[^\/]+/) do # EDS identifier rules (e.g., db__acid) where acid has all sorts of different punctuation
    resources :articles, only: %i[index] do
      concerns :exportable

      collection do
        get 'search_bar'
      end
    end

    get 'articles/:id' => 'articles#show', as: :eds_document

    get 'articles/:id/ris' => 'articles#show', as: :articles_ris, constraints: ->(req) { req.format = :ris }

    post 'articles/:id/track' => 'articles#track', as: :track_articles
    get 'articles/:id/fulltext' => 'articles#fulltext_html', as: :article_html_fulltext
    get 'articles/:id/:type/fulltext' => 'articles#fulltext_link', as: :article_fulltext_link, constraints: { type: /[-\w]+/ }
  end

  # Vanity URL used in development office mailings
  get '/funds/:fund', to: redirect { |path_params, _req| "/?f[fund_facet][]=#{path_params[:fund].upcase}" }

  direct :bookplate_search do |bookplate|
    { controller: '/catalog', action: 'index', f: { fund_facet: [bookplate.druid] }, view: 'gallery', sort: 'new-to-libs' }
  end

  %w(404 500).each do |code|
    match code, to: 'errors#show', code: code, via: :all
  end

  Rails.application.routes.draw do
    mount Lookbook::Engine, at: "/lookbook"
  end
end
