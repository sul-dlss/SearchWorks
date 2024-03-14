# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy Symphony catkey Routing' do
  it 'redirects FOLIO hrids to the symphony equivalents' do
    get '/view/a12345'

    expect(response).to redirect_to('/view/12345')
  end
end
