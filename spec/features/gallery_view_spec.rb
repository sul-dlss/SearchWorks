require 'rails_helper'

RSpec.feature 'Gallery View' do
  scenario 'Search results are rendered properly', :js do
    visit search_catalog_path f: { format: ['Book'] }
    within '#view-type-dropdown' do
      click_button 'View'
      click_link 'gallery'
    end

    expect(page).to have_css('i.fa.fa-th')
    expect(page).to have_css('div.callnumber-bar', text: 'ABC')
    expect(page).to have_css('div.callnumber-bar', count: 2, text: /./)
    expect(page).to have_css(
      ".gallery-document a[tabindex='-1'] span.fake-cover", text: 'An object', visible: true
    )

    expect(page).to have_css('.gallery-document a div.fake-cover-text', text: 'Car : a drama of the American workplace', visible: :hidden)

    expect(page).to have_css('.gallery-document h3.index_title', text: 'An object')
    expect(page).to have_css('.gallery-document button.btn-preview', text: 'Preview')
    expect(page).to have_css('form.bookmark-toggle label.toggle-bookmark', text: 'Select')
    expect(page).to have_css("label[for='toggle-bookmark_1']", count: 1)
    page.first('button.btn.docid-1').click
    expect(page).to have_css("label[for='toggle-bookmark_1']", count: 1)
    within '.preview-container' do
      expect(page).to have_css('h3', text: 'An object')
    end
  end
end
