require 'spec_helper'

describe 'Callnumber Browse', type: :feature, js: true do
  describe 'embedded on the record page' do
    it 'renders' do
      visit catalog_path('1')

      expect(page).to have_css('h2', text: 'Browse related items')
    end
  end

  describe 'full browse view' do
    it 'is successful' do
      visit catalog_path('1')

      within '.record-browse-nearby' do
        click_link 'View full page'
      end

      expect(page).to have_css('h1', text: 'Browse related items')
    end
  end
end
