# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stackmap' do
  it 'renders the page' do
    get '/view/4/GRE-STACKS/stackmap'

    expect(response).to have_http_status(:ok)
  end
end
