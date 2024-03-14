# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Article Routing' do
  it '#index' do
    expect(get('/articles')).to route_to('articles#index')
  end

  context '#show' do
    let(:uri) { "/articles/#{Addressable::URI.encode_component(id)}" }

    subject(:result) { get(uri) }

    context 'handles EDS identifiers' do
      let(:id) { 'eds__1(2).3-4~5,6;7|8%9:A_b' }

      it 'route to the show page' do
        expect(result).to route_to(controller: 'articles', action: 'show', id:)
      end

      context 'identifier with an encoded semicolon' do
        let(:id) { 'eds__idwith%3bsemicolon' }

        it 'routes to the page with the appropriate identifier' do
          expect(result).to route_to(controller: 'articles', action: 'show', id: 'eds__idwith;semicolon')
        end
      end
    end

    context 'rejects unknown identifiers' do
      let(:id) { 'eds__1 2/3' }

      it 'should not route to show page' do
        expect(result).not_to be_routable
      end
    end
  end

  it '#track' do
    expect(post('/articles/eds__1/track')).to route_to(controller: 'articles', action: 'track', id: 'eds__1')
  end
  it '#fulltext' do
    expect(get('/articles/eds__1/ebook-pdf/fulltext')).to route_to(controller: 'articles', action: 'fulltext_link', id: 'eds__1', type: 'ebook-pdf')
    expect(get('/articles/eds__1/wrong type/fulltext')).not_to be_routable
  end

  it '#backend_lookup' do
    expect(get('/articles/backend_lookup')).to route_to(controller: 'articles', action: 'backend_lookup', format: :json)
  end

  it 'other actions are not routable' do
    expect(post('/articles')).not_to be_routable
    expect(put('/articles')).not_to be_routable
    expect(delete('/articles')).not_to be_routable
  end
end
