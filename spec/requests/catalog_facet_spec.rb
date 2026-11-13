# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Catalog facet modal' do
  context 'with a facet that is not configured' do
    it 'returns a 404' do
      get '/catalog/facet/callnum_top_facet'

      expect(response).to have_http_status :not_found
    end
  end
end
