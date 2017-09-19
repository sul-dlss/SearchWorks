Rails.application.routes.draw do
  root to: 'quick_search/search#index'
  mount QuickSearch::Engine => '/all'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
