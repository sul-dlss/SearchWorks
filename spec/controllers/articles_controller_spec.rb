# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticlesController do
  include Devise::Test::ControllerHelpers
  it 'should include the EmailValidation concern' do
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

      context 'with an empty query' do
        it 'sets a flash error and redirects' do
          get :index, params: { q: '' }

          expect(flash[:alert]).to eq(
            'An empty search is not possible in articles+. Enter a keyword to start your search.'
          )

          expect(response).to redirect_to(articles_path)
        end
      end

      context 'with a query' do
        it 'raises the error' do
          expect do
            get :index, params: { q: 'A query' }
          end.to raise_error(EBSCO::EDS::BadRequest)
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
      stub_article_service(type: :single, docs: [SolrDocument.new(id: '123',
                                                                  eds_fulltext_links: [{ url: 'http://example.com/file.pdf', type: 'pdf' }])])
      get :fulltext_link, params: { id: '123', type: :pdf }
      expect(response).to redirect_to('http://example.com/file.pdf')
    end

    describe 'errors on missing links' do
      before do
        stub_article_service(
          type: :single,
          docs: [
            SolrDocument.new(id: '123', eds_fulltext_links: [{ url: 'detail', type: 'pdf' }])
          ]
        )
      end

      context 'when the user is in guest mode' do
        before { session['eds_guest'] = true }

        it 'returns an error message indicating to login to view the content' do
          get :fulltext_link, params: { id: '123', type: :pdf }
          error_message = Capybara.string(flash[:error])
          expect(error_message).to have_content(
            'Sorry, the PDF download was not successful because you are currently in guest mode.'
          )
          expect(error_message).to have_content('Log in to try the download again')
          expect(response).to have_http_status(:found) # redirects back
        end

        it 'does not send an exception to Honeybadger (because this can be expected)' do
          expect(Honeybadger).not_to receive(:notify)

          get :fulltext_link, params: { id: '123', type: :pdf }
        end
      end

      context 'when the user is not in guest mode' do
        before do
          allow(controller).to receive(:current_user).and_return(User.new)
          session['eds_guest'] = false
        end

        it 'returns an error message indicating to report it as a connection problem' do
          get :fulltext_link, params: { id: '123', type: :pdf }
          error_message = Capybara.string(flash[:error])
          expect(error_message).to have_content 'Sorry, the PDF download was not successful'
          expect(error_message).to have_content 'We don\'t know the source of the error.'
          expect(error_message).to have_css('a', text: 'please report it as a connection problem')
          expect(response).to have_http_status(:found) # redirects back
        end

        it 'sends and exception notification' do
          expect(Honeybadger).to receive(:notify)

          get :fulltext_link, params: { id: '123', type: :pdf }
        end
      end
    end
  end

  it 'handles authentication'
  it 'handles configuration'

  context 'EDS Session Management' do
    let(:user_session) { {} }
    let(:eds_session) { instance_double(EBSCO::EDS::Session, session_token: 'abc') }

    before do
      allow(controller).to receive_messages(session: user_session, on_campus_or_su_affiliated_user?: true)
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
    it 'will require the session token in the user session data' do
      user_session['eds_guest'] = false
      expect(EBSCO::EDS::Session).to receive(:new).and_return(eds_session)
      controller.eds_init
    end
  end

  describe '#email' do
    before { stub_article_service(type: :single, docs: [SolrDocument.new(id: '123')]) }

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
