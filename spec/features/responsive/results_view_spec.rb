require 'rails_helper'

RSpec.describe 'Responsive results view Page', feature: true, js: true do
  describe 'facets' do
    before do
      visit search_catalog_path f: { access_facet: ['Online'] }
    end

    it 'should show previous/next on large screens' do
      within('ul.pagination') do
        expect(page).to have_css('span', text: 'Previous', visible: true)
      end

      within('ul.pagination') do
        expect(page).to have_css('span', text: 'Previous', visible: false)
      end
    end
  end
end
