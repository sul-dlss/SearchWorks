require 'rails_helper'

RSpec.describe LoginController do
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
  end
end
