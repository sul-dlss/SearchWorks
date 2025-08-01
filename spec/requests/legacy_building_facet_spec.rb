# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy building_facet routing' do
  it 'redirects building_facet to the library_code_facet_ssim equivalent' do
    get '/?f[building_facet][]=Business&f[language][]=English&search_field=search&q=transformative'

    expect(response).to redirect_to '/catalog?f%5Blanguage%5D%5B%5D=English&f%5Blibrary%5D%5B%5D=BUSINESS&q=transformative&search_field=search'
  end

  context 'with a malformed building_facet value (providing an index)' do
    it 'redirects building_facet to the library_code_facet_ssim equivalent' do
      get '/?f[building_facet][0]=Business&f[language][]=English&search_field=search&q=transformative'

      expect(response).to redirect_to '/catalog?f%5Blanguage%5D%5B%5D=English&f%5Blibrary%5D%5B%5D=BUSINESS&q=transformative&search_field=search'
    end
  end
end
