require 'spec_helper'

RSpec.describe ArticleController do
  context '#index' do
    it 'shows a home page' do
      stub_article_service(docs: [SolrDocument.new(id: 'abc123')])
      get :index
      expect(response).to render_template('index')
    end
  end

  context '#show' do
    it 'shows a detail page' do
      stub_article_service(type: :single, docs: [SolrDocument.new(id: '123')])
      get :show, params: { id: '123' }
      expect(response).to render_template('show')
    end
  end

  it 'handles authentication'
  it 'handles configuration'

  context 'EDS Session Management' do
    let(:user_session) { {} }
    let(:eds_session) { instance_double(EBSCO::EDS::Session, session_token: 'abc') }
    before do
      allow(controller).to receive(:session).and_return(user_session)
      allow(controller).to receive(:eds_authenticated_user?).and_return(true)
    end
    it 'will create a new session' do
      expect(EBSCO::EDS::Session).to receive(:new).with(
        hash_including(caller: 'new-session', guest: false)
      ).and_return(eds_session)
      controller.eds_init
    end
    it 'will reuse the session if in the user session data' do
      user_session['eds_guest'] = false
      user_session['eds_session_token'] = 'def'
      expect(EBSCO::EDS::Session).not_to receive(:new)
      controller.eds_init
    end
    it 'will require the guest mode in the user session data' do
      user_session['eds_session_token'] = 'def'
      expect(EBSCO::EDS::Session).to receive(:new).and_return(eds_session)
      controller.eds_init
    end
    it 'will require the session token in the user session data' do
      user_session['eds_guest'] = false
      expect(EBSCO::EDS::Session).to receive(:new).and_return(eds_session)
      controller.eds_init
    end
  end
end
