# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DOI queries' do
  it 'bounces you to the DOI endpoint' do
    get '/?q=doi:10.1109/5.771073'
    expect(response).to redirect_to('http://doi.org/10.1109%2F5.771073')
  end
end
