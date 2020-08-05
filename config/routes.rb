Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'search#index'
  get 'opensearch' => 'opensearch#opensearch', :defaults => { :format => 'xml' }
  get 'xhr_search' => 'search#xhr_search', :defaults => { :format => 'html' }
end
