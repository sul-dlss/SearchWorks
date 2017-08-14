require 'spec_helper'

RSpec.describe 'Article Routing', type: :routing do
  it '#index' do
    expect(get('/articles')).to route_to('articles#index')
  end
  it '#show' do
    expect(get('/articles/1')).to route_to(controller: 'articles', action: 'show', id: '1')
    expect(get('/articles/eds__style1')).to route_to(controller: 'articles', action: 'show', id: 'eds__style1')
    expect(get('/articles/eds__Style2-with-hyphens')).to route_to(controller: 'articles', action: 'show', id: 'eds__Style2-with-hyphens')
    expect(get('/articles/eds__Style2-with~tildes')).to route_to(controller: 'articles', action: 'show', id: 'eds__Style2-with~tildes')
    expect(get('/articles/eds__Style2-with+pluses')).to route_to(controller: 'articles', action: 'show', id: 'eds__Style2-with+pluses')
    expect(get('/articles/eds__Style2-with%3bsemicolon')).to route_to(controller: 'articles', action: 'show', id: 'eds__Style2-with;semicolon')
  end
  it '#track' do
    expect(post('/articles/1/track')).to route_to(controller: 'articles', action: 'track', id: '1')
    expect(post('/articles/eds__style1/track')).to route_to(controller: 'articles', action: 'track', id: 'eds__style1')
    expect(post('/articles/eds__Style2-with-hyphens/track')).to route_to(controller: 'articles', action: 'track', id: 'eds__Style2-with-hyphens')
    expect(post('/articles/eds__Style2-with~tildes/track')).to route_to(controller: 'articles', action: 'track', id: 'eds__Style2-with~tildes')
    expect(post('/articles/eds__Style2-with+pluses/track')).to route_to(controller: 'articles', action: 'track', id: 'eds__Style2-with+pluses')
  end
  it 'other actions are not routable' do
    expect(post('/articles')).not_to be_routable
    expect(put('/articles')).not_to be_routable
    expect(delete('/articles')).not_to be_routable
  end
end
