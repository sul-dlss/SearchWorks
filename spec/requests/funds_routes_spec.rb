# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Funds vanity url routing' do
  it 'redirects to the fund search path (and upcases the fund name)' do
    get '/funds/woods'

    expect(response).to redirect_to('/?f[fund_facet][]=WOODS')
  end
end
