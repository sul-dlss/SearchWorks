require 'spec_helper'

RSpec.describe ArticlesController do
  include Devise::Test::ControllerHelpers
  it 'should include the EmailValidation concern' do
    expect(subject).to be_kind_of(EmailValidation)
  end

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

  describe '#eds_authenticated_user?' do
    context 'when there is a current user' do
      before do
        expect(controller).to receive(:current_user).and_return(double('User'))
      end

      it { expect(controller.send(:eds_authenticated_user?)).to be true }
    end

    context 'when there is not a current user' do
      it { expect(controller.send(:eds_authenticated_user?)).to be false }
    end
  end

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

  describe '#email' do
    before {stub_article_service(type: :single, docs: [SolrDocument.new(id: '123')])}
    it 'should set the provided subject' do
      expect { post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief', id: '123' } }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq 'Email Subject'
    end
    it 'should send a brief email when requested' do
      email = double('email')
      expect(SearchWorksRecordMailer).to receive(:article_email_record).and_return(email)
      expect(email).to receive(:deliver_now)
      post :email, params: { to: 'email@example.com', subject: 'Email Subject', type: 'brief', id: '123' }
    end

    it 'should be able to send emails to multiple addresses' do
      expect do
        post :email, params: { to: 'e1@example.com, e2@example.com, e3@example.com', subject: 'Subject', type: 'full', id: '123' }
      end.to change { ActionMailer::Base.deliveries.count }.by(3)
    end
  end
end
