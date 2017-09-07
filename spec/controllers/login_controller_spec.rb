require 'spec_helper'

describe LoginController do
  describe 'login' do
    it 'redirects back to the referrer param' do
      get :login, params: { referrer: '/some_url' }
      expect(response).to redirect_to '/some_url'
    end

    it 'redirects to the HTTP_REFERER if no referrer param is passed' do
      request.env['HTTP_REFERER'] = '/some_url'
      get :login
      expect(response).to redirect_to '/some_url'
    end

    describe 'eds_guest session flag' do
      context 'when the user is in guest mode' do
        before { session['eds_guest'] = true }

        it 'sets the flag to nil (so it can be reset in the ArticlesController)' do
          get :login

          expect(session['eds_guest']).to be_nil
        end
      end

      context 'when the user is not in guest mode' do
        before { session['eds_guest'] = false }

        it 'sets keeps the flag as-is (so the EDS Session can be re-used)' do
          get :login

          expect(session['eds_guest']).to be false
        end
      end
    end

    describe 'suAffiliation session attribute' do
      it 'is set to the request.env attribute when present' do
        expect(request).to receive(:env).and_return('suAffiliation' => 'stanford:stanford')

        get :login

        expect(session['suAffiliation']).to eq 'stanford:stanford'
      end

      it 'is set to the ENV attribute when present' do
        expect(ENV).to receive(:[]).with('suAffiliation').and_return('stanford:staff')

        get :login

        expect(session['suAffiliation']).to eq 'stanford:staff'
      end
    end
  end
end
