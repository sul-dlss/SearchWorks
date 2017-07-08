require 'spec_helper'

RSpec.describe 'Article Routing', type: :routing do
  it '#index' do
    expect(get('/article')).to route_to('article#index')
  end
  it '#show' do
    expect(get('/article/1')).to route_to(controller: 'article', action: 'show', id: '1')
  end

  it '#facet' do
    expect(get('/article/some_facet_field/facet')).to route_to(controller: 'article', action: 'facet', id: 'some_facet_field')
  end

  it 'other actions are not routable' do
    expect(post('/article')).not_to be_routable
    expect(put('/article')).not_to be_routable
    expect(delete('/article')).not_to be_routable
  end
end
