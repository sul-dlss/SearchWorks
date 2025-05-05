# frozen_string_literal: true

require 'rails_helper'

# This feature is not linked to in the UI, but we it is helpful tool for finding records with specifc marc fields if you know the path.
RSpec.describe 'Searching for records with a specific MARC field' do
  it 'returns results' do
    get '/?search_field=search&q=context_marc_fields_ssim%3A710ab'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include '4 catalog results'
    expect(response.body).to include 'The gases of swamp rice soils'
    expect(response.body).to include 'World 1:500,000'
    expect(response.body).to include 'The retention of soluble phosphates in calcareous and non-calcareous soils'
    expect(response.body).to include 'Adaptation and regularization of deep neural networks under temporal smoothness assumption'
  end
end
