require 'spec_helper'

RSpec.describe 'Article Routing' do
  it '#new' do
    expect(get new_article_path).to route_to('article#new', format: :html)
  end
  it '#home is an alias to #new' do
    expect(get article_home_path).to route_to('article#new')
  end
end
