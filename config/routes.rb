# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "catalog#index"

  # redirect Symphony-migrated FOLIO HRIDs to their original Symphony URLs
  constraints(id: /a\d+/) do
    get '/view/:id', to: redirect { |path_params, _req| "/view/#{path_params[:id].delete_prefix('a')}" }
  end

  get "view/:id/librarian_view" => "catalog#librarian_view", as: :librarian_view
  get "view/:id/:location/stackmap" => "catalog#stackmap", as: :stackmap

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/' if Settings.GENERATE_SITEMAP

  mount BlacklightAdvancedSearch::Engine => '/'

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
  end

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]

    member do
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
    concerns :searchable
    concerns :range_searchable
  end
  post 'databases/:id/track' => 'databases#track', as: :track_databases

  get 'govdocs' => 'catalog#index', defaults: { f: { genre_ssim: ['Government document'] } }, as: :govdocs

  resources :hours, only: :show

  resource :feedback_form, path: "feedback", only: [:new, :create]

  resource :quick_reports, only: [:create]

  resources :lib_guides, only: :index

  resources :browse, only: :index

  get 'catalog/:id/track' => 'catalog#track', as: 'track_browse'
  get 'catalog/:id/track' => 'catalog#track', as: 'track_preview'
  get 'catalog/:id/track' => 'articles#track', as: 'track_article_selections'

  get "browse/nearby" => "browse#nearby"

  get "feedback" => "feedback_forms#new"

  resources :preview, only: :show

  resources :availability, only: [:index, :show]

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

  %w(404 500).each do |code|
    match code, to: 'errors#show', code: code, via: :all
  end

  Rails.application.routes.draw do
    mount Lookbook::Engine, at: "/lookbook"
  end
end
