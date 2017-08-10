require 'spec_helper'

RSpec.describe 'Article Routing', type: :routing do
  it '#index' do
    expect(get('/article')).to route_to('article#index')
  end
  it '#show' do
    expect(get('/article/1')).to route_to(controller: 'article', action: 'show', id: '1')
    expect(get('/article/eds__style1')).to route_to(controller: 'article', action: 'show', id: 'eds__style1')
    expect(get('/article/eds__Style2-with-hyphens')).to route_to(controller: 'article', action: 'show', id: 'eds__Style2-with-hyphens')
    expect(get('/article/eds__Style2-with~tildes')).to route_to(controller: 'article', action: 'show', id: 'eds__Style2-with~tildes')
    expect(get('/article/eds__Style2-with+pluses')).to route_to(controller: 'article', action: 'show', id: 'eds__Style2-with+pluses')
    expect(get('/article/eds__Style2-with%3bsemicolon')).to route_to(controller: 'article', action: 'show', id: 'eds__Style2-with;semicolon')
  end
  it '#track' do
    expect(post('/article/1/track')).to route_to(controller: 'article', action: 'track', id: '1')
    expect(post('/article/eds__style1/track')).to route_to(controller: 'article', action: 'track', id: 'eds__style1')
    expect(post('/article/eds__Style2-with-hyphens/track')).to route_to(controller: 'article', action: 'track', id: 'eds__Style2-with-hyphens')
    expect(post('/article/eds__Style2-with~tildes/track')).to route_to(controller: 'article', action: 'track', id: 'eds__Style2-with~tildes')
    expect(post('/article/eds__Style2-with+pluses/track')).to route_to(controller: 'article', action: 'track', id: 'eds__Style2-with+pluses')
  end
  it 'other actions are not routable' do
    expect(post('/article')).not_to be_routable
    expect(put('/article')).not_to be_routable
    expect(delete('/article')).not_to be_routable
  end
end
