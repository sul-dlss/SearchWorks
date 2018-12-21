Rails.application.routes.draw do
  mount OkComputer::Engine, at: "/status"

  root to: 'quick_search/search#index'

  # Disable all of the appstats pages
  match '/all/appstats', to: redirect('/all'), via: %i[get post]
  match '/all/appstats/clicks_overview', to: redirect('/all'), via: %i[get post]
  match '/all/appstats/top_searches', to: redirect('/all'), via: %i[get post]
  match '/all/appstats/top_spot', to: redirect('/all'), via: %i[get post]
  match '/all/appstats/detail/:ga_scope', to: redirect('/all'), via: %i[get post]
  match '/all/appstats/realtime', to: redirect('/all'), via: %i[get post]

  mount QuickSearch::Engine => '/all'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/about', to: redirect('/all')
end
