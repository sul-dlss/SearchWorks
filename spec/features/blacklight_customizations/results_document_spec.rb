require 'rails_helper'

RSpec.describe 'Results Document Metadata' do
  it 'has correct title with open-ended date range and metadata' do
    visit root_path
    fill_in 'search for', with: '1'
    click_button 'search'

    within '#documents' do
      expect(page).to have_css('a', text: 'An object', visible: true)
      expect(page).to have_css('span.main-title-date', text: '[2000 - ]', visible: false)
    end
  end

  it "has 'sometime between' date range" do
    visit root_path
    fill_in 'search for', with: '11'
    click_button 'search'

    within '#documents' do
      expect(page).to have_css('span.main-title-date', text: '[1801 ... 1837]', visible: false)
    end
  end

  it 'has the stacks image for objects with image behavior' do
    visit root_path
    fill_in 'search for', with: '35'
    click_button 'search'

    within 'article.document' do
      within('.document-thumbnail') do
        expect(page).to have_css('img.stacks-image')
        expect(page).to have_css('img.stacks-image[alt=""]')
        expect(page).to have_link 'IIIF Drag-n-drop'
      end
    end
  end
end
