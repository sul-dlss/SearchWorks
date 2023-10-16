require 'rails_helper'

RSpec.describe QuickReportsController do
  describe 'format json' do
    it 'should return json success' do
      post :create, params: { url: 'http://www.example.com/view/123', format: 'json' }
      expect(flash[:success]).to eq '<strong>Thank you!</strong> Your feedback has been sent.'
    end
    it 'should return html success' do
      post :create, params: { url: 'http://www.example.com/view/123' }
      expect(flash[:success]).to eq '<strong>Thank you!</strong> Your feedback has been sent.'
    end
  end
end
