require 'spec_helper'

RSpec.describe 'Article Routing', type: :routing do
  it '#new' do
    expect(get('/article/new')).to route_to('article#new', format: :html)
  end
  it '#home is an alias to #new' do
    expect(get('/article/home')).to route_to('article#new')
  end
  it '#index' do
    expect(get('/article')).to route_to('article#index', format: :html)
  end
  it '#show' do
    expect(get('/article/1')).to route_to(format: :html, controller: 'article', action: 'show', id: '1')
  end
  it 'other actions are not routable' do
    expect(post('/article')).not_to be_routable
    expect(put('/article')).not_to be_routable
    expect(delete('/article')).not_to be_routable
  end
end
