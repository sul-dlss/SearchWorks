# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stackmap' do
  it 'renders the page' do
    get '/view/1/stackmap', params: { library: 'GREEN' }

    expect(response).to have_http_status(:ok)
  end

  context 'when the library parameter is missing' do
    it 'raises an error' do
      expect { get '/view/1/stackmap' }.to raise_error ActionController::ParameterMissing
    end
  end
end
