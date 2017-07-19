Rails.application.routes.draw do
  root :to => "catalog#index"

  get "view/:id/librarian_view" => "catalog#librarian_view", :as => :librarian_view
  get "view/:id/stackmap" => "catalog#stackmap", :as => :stackmap

  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/view', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  Blacklight::Marc.add_routes(self)
  devise_for :users, skip: [:registrations, :passwords, :sessions]
  devise_scope :user do
    get 'webauth/login' => 'login#login', as: :new_user_session
    match 'webauth/logout' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  get "databases" => "catalog#index", :defaults => {:f => {:format_main_ssim=>["Database"]}}

  get 'govdocs' => 'catalog#index', defaults: { f: { genre_ssim: ['Government document'] } }, as: :govdocs

  resources :selected_databases, only: :index

  resources :hours, only: :show

  resource :feedback_form, path: "feedback", only: [:new, :create]

  resource :quick_reports, only: [:create]

  resources :embed, only: :show

  resources :browse, only: :index

  get "browse/nearby" => "browse#nearby"

  get "feedback" => "feedback_forms#new"
  get "backend_lookup" => "catalog#backend_lookup", defaults: {format: :json}, as: :catalog_backend_lookup

  get 'view/:id/availability' => 'catalog#availability', defaults: { format: :json }

  resources :preview, only: :show

  resources :availability, only: :index

  get "selections" => "bookmarks#index"

  resources :recent_selections, only: :index

  resources :course_reserves, only: :index, path: "reserves"

  constraints(id: /[-~\w]+/) do # EDS identifier rules (e.g., db__id)
    resources :article, only: %i[index show]
    post "article/:id/track" => 'article#track', as: :track_article
  end
end
