require 'rails_helper'

RSpec.feature 'Results Document Metadata' do
  scenario 'should have correct tile with open-ended date range and metadata' do
    visit root_path
    first('#q').set '1'
    click_button 'search'

    within '#documents' do
      expect(page).to have_css('a', text: 'An object', visible: true)
      expect(page).to have_css('span.main-title-date', text: '[2000 - ]', visible: false)
    end
  end

  scenario "should have 'sometime between' date range" do
    visit root_path
    first('#q').set '11'
    click_button 'search'

    within '#documents' do
      expect(page).to have_css('span.main-title-date', text: '[1801 ... 1837]', visible: false)
    end
  end

  scenario 'should have correct cover image attributes', js: true do
    skip('Google Books API not working under test')
    visit root_path
    first('#q').set '10'
    click_button 'search'

    within '#documents' do
      within 'div.document' do
        expect(page).to have_css('img.cover-image', visible: true)
        expect(page).to have_css('img.cover-image.ISBN0393040801.ISBN9780393040807.OCLC36024029.LCCN96049953', visible: true)
        expect(page).to have_css("img.cover-image[data-isbn='ISBN0393040801,ISBN9780393040807']", visible: true)
        expect(page).to have_css("img.cover-image[data-lccn='LCCN96049953']", visible: true)
        expect(page).to have_css("img.cover-image[data-oclc='OCLC36024029']", visible: true)
        expect(find('img.cover-image')['src']).to match /books\.google\.com\/.*id=crOdQgAACAAJ/
      end
    end
  end

  scenario 'should have the correct cover image wrapper attributes' do
    visit root_path
    first('#q').set '10'
    click_button 'search'

    within '#documents' do
      within 'div.document' do
        expect(page).to have_css('div.cover-image-wrapper', visible: true)
        expect(page).to have_css("div.cover-image-wrapper[data-target='/view/10']")
        expect(page).to have_css("div.cover-image-wrapper[data-context-href^='/catalog/10/track?']")
      end
    end
  end

  scenario 'should have the stacks image for objects with image behavior' do
    visit root_path
    first('#q').set '35'
    click_button 'search'

    within 'div.document' do
      within('.document-thumbnail') do
        expect(page).to have_css('img.stacks-image')
        expect(page).to have_css('img.stacks-image[alt=""]')
      end
    end
  end
end
