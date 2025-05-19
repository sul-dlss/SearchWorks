# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching the catalog' do
  context 'with special characters' do
    it 'returns results' do
      get '/catalog', params: { q: 'What does a woman want? : reading and sexual difference', search_field: 'search' }

      expect(response).to have_http_status(:ok)
    end
  end
end
