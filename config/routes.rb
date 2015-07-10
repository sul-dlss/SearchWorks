Rails.application.routes.draw do
  root :to => "catalog#index"

  get "view/:id" => "catalog#show", :as => :catalog
  get "view/:id" => "catalog#show", :as => :solr_document
  get "view/:id/librarian_view" => "catalog#librarian_view", :as => :librarian_view
  get "view/:id/stackmap" => "catalog#stackmap", :as => :stackmap
  post "catalog/sms" => 'catalog#sms' # we can remove when we upgrade to Blacklight > 5.5.2

  blacklight_for(:catalog)
  Blacklight::Marc.add_routes(self)
  devise_for :users, skip: [:registrations, :passwords, :sessions]
  devise_scope :user do
    get 'webauth/login' => 'login#login', as: :new_user_session
    match 'webauth/logout' => 'devise/sessions#destroy', :as => :destroy_user_session, :via => Devise.mappings[:user].sign_out_via
  end

  get "databases" => "catalog#index", :defaults => {:f => {:format_main_ssim=>["Database"]}}

  resources :selected_databases, only: :index

  resources :hours, only: :show

  resource :feedback_form, path: "feedback", only: [:new, :create]

  resource :quick_reports, only: [:create]

  resources :embed, only: :show

  resources :browse, only: :index

  get "browse/nearby" => "browse#nearby"

  get "feedback" => "feedback_forms#new"
  get "backend_lookup" => "catalog#backend_lookup", defaults: {format: :json}, as: :catalog_backend_lookup

  resources :preview, only: :show

  resources :availability, only: :index

  get "selections" => "bookmarks#index"

  resources :recent_selections, only: :index

  resources :course_reserves, only: :index, path: "reserves"

  resources :annotations, except: [:update, :edit, :destroy]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
