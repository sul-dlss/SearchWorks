require 'spec_helper'

RSpec.describe ArticleController do
  context '#index' do
    it 'shows a home page' do
      stub_article_service(docs: [SolrDocument.new(id: 'abc123')])
      get :index
      expect(response).to render_template('index')
    end
  end

  it 'handles authentication'
  it 'handles configuration'

  context 'Article Search API (via EDS)' do
    before do
      expect(EBSCO::EDS::Session).to receive(:new).and_return(
        instance_double(EBSCO::EDS::Session, session_token: double)
      )
      @search_service = instance_double(Eds::SearchService)
      expect(Eds::SearchService).to receive(:new).and_return(@search_service)
    end

    it '#index' do
      expect(@search_service).to receive(:search_results)
      get :index
    end

    it '#show' do
      expect(@search_service).to receive(:fetch).with('123')
      get :show, params: { id: 123 }
    end
  end

  context 'EDS Session Management' do
    let(:user_session) { {} }
    let(:eds_session) { instance_double(EBSCO::EDS::Session, session_token: 'abc') }
    before { allow(controller).to receive(:session).and_return(user_session) }
    it 'will create a new session' do
      expect(EBSCO::EDS::Session).to receive(:new).with(
        hash_including(caller: 'new-session', guest: true)
      ).and_return(eds_session)
      controller.eds_init
    end
    it 'will reuse the session if in the user session data' do
      user_session['eds_session_token'] = 'def'
      expect(EBSCO::EDS::Session).not_to receive(:new)
      controller.eds_init
    end
  end
end
