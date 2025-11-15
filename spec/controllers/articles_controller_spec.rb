# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticlesController do
  include Devise::Test::ControllerHelpers
  it 'includes the EmailValidation concern' do
    expect(subject).to be_a(EmailValidation)
  end

  describe '#index' do
    it 'shows a home page' do
      stub_article_service(docs: [SolrDocument.new(id: 'abc123')])
      get :index
      expect(response).to render_template('index')
    end

    context 'when a query causes an EDS error' do
      before { stub_article_service(type: :error, docs: []) }

      context 'with a query' do
        it 'raises the error' do
          expect do
            get :index, params: { q: 'A query' }
          end.to raise_error(Faraday::Error)
        end
      end
    end

    context 'when EDS is disabled' do
      before do
        allow(Settings).to receive(:EDS_ENABLED).and_return(false)
      end

      it 'sets a flash alert and redirects' do
        get :index

        expect(flash[:alert]).to eq(
          'Article+ search is not enabled'
        )

        expect(response).to redirect_to(root_path)
      end

      context 'for a json request' do
        it 'renders an error' do
          get :index, format: :json

          expect(flash[:alert]).to eq(
            'Article+ search is not enabled'
          )

          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe '#show' do
    it 'shows a detail page' do
      stub_article_service(type: :single, docs: [SolrDocument.new(id: '123')])
      get :show, params: { id: '123' }
      expect(response).to render_template('show')
    end

    context 'when a BadReqest error is returned from the API (which we have to assume means the record is not found)' do
      before { stub_article_service(type: :error, docs: []) }

      it 'raises a not found error' do
        expect do
          get :show, params: { id: '123' }
        end.to raise_error(ActionController::RoutingError, 'Not Found')
      end
    end
  end

  describe '#fulltext_link' do
    it 'redirect to a fulltext link' do
      stub_article_service(type: :single, docs: [instance_double(EdsDocument, id: '123', eds_fulltext_links: [{ url: 'http://example.com/file.pdf', type: 'pdflink' }])])
      get :fulltext_link, params: { id: '123', type: 'pdf' }
      expect(response).to redirect_to('http://example.com/file.pdf')
    end

    describe 'errors on missing links' do
      before do
        stub_article_service(
          type: :single,
          docs: [instance_double(EdsDocument, id: '123', eds_fulltext_links: [{ url: 'detail', type: 'pdf' }])]
        )
      end

      context 'when the user is in guest mode' do
        before do
          # allows the before action to set session['eds_guest'] to true
          allow(IPRange).to receive(:includes?).and_return(false)
        end

        it 'returns an error message indicating to login to view the content' do
          get :fulltext_link, params: { id: '123', type: 'pdf' }
          error_message = Capybara.string(flash[:error])
          expect(error_message).to have_content(
            'Sorry, the PDF download was not successful because you are currently in guest mode.'
          )
          expect(error_message).to have_content('Log in to try the download again')
          expect(response).to have_http_status(:found) # redirects back
        end

        it 'does not send an exception to Honeybadger (because this can be expected)' do
          expect(Honeybadger).not_to receive(:notify)

          get :fulltext_link, params: { id: '123', type: 'pdf' }
        end
      end

      context 'when the user is not in guest mode' do
        before do
          allow(controller).to receive(:current_user).and_return(User.new)
          # allows the before action to set session['eds_guest'] to false
          allow(IPRange).to receive(:includes?).and_return(true)
        end

        it 'returns an error message indicating to report it as a connection problem' do
          get :fulltext_link, params: { id: '123', type: 'pdf' }
          error_message = Capybara.string(flash[:error])
          expect(error_message).to have_content 'Sorry, the PDF download was not successful'
          expect(error_message).to have_content 'We don\'t know the source of the error.'
          expect(error_message).to have_css('a', text: 'please report it as a connection problem')
          expect(response).to have_http_status(:found) # redirects back
        end

        it 'sends and exception notification' do
          expect(Honeybadger).to receive(:notify)

          get :fulltext_link, params: { id: '123', type: 'pdf' }
        end
      end
    end
  end

  it 'handles authentication'
  it 'handles configuration'

  context 'EDS Session Management' do
    let(:user_session) { {} }
    let(:eds_session) { instance_double(Eds::Session, session_token: 'abc') }

    before do
      allow(controller).to receive_messages(session: user_session, on_campus_or_su_affiliated_user?: true)
      allow(controller).to receive(:search_service).and_return(double(session_token: 'abc'))
    end

    it 'creates a new session' do
      expect(Eds::Session).to receive(:new).with(
        hash_including(caller: 'new-session', guest: false)
      ).and_return(eds_session)
      controller.manage_eds_session_token { true }
    end
    it 'reuses the session if in the user session data' do
      user_session['eds_guest'] = false
      user_session[Settings.EDS_SESSION_TOKEN_KEY] = 'def'
      expect(Eds::Session).not_to receive(:new)
      controller.manage_eds_session_token { true }
    end
    it 'requires the session token in the user session data' do
      user_session['eds_guest'] = false
      expect(Eds::Session).to receive(:new).and_return(eds_session)
      controller.manage_eds_session_token { true }
    end

    it 'rotates the session key if the session token changes' do
      expect(Eds::Session).to receive(:new).with(
        hash_including(caller: 'new-session', guest: false)
      ).and_return(eds_session)

      allow(controller).to receive(:search_service).and_return(double(session_token: 'xyz'))
      controller.manage_eds_session_token { true }

      expect(user_session[Settings.EDS_SESSION_TOKEN_KEY]).to eq 'xyz'
    end
  end
end
