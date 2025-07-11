# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuickReportsController do
  describe 'format json' do
    it 'returns json success' do
      post :create, params: { url: "#{request.url}/view/123", format: 'json' }
      expect(flash[:success]).to eq '<strong>Thank you!</strong> <br/> Your feedback has been sent.'
    end

    it 'returns html success' do
      post :create, params: { url: "#{request.url}/view/123" }
      expect(flash[:success]).to eq '<strong>Thank you!</strong> <br/> Your feedback has been sent.'
    end
  end
end
