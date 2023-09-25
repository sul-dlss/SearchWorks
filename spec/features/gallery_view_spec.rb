require 'spec_helper'

feature 'Gallery View' do
  scenario 'Search results are rendered properly', js: true do
    visit search_catalog_path f: { format: ['Book'] }
    page.find('#view-type-dropdown button.dropdown-toggle').click
    page.find('#view-type-dropdown .dropdown-menu li a.view-type-gallery').click

    wait_for_ajax

    expect(page).to have_css('i.fa.fa-th')
    expect(page).to have_css('div.callnumber-bar', text: 'ABC')
    expect(page).to have_css('div.callnumber-bar', count: 2, text: /./)
    expect(page).to have_css(
      ".gallery-document a[tabindex='-1'] span.fake-cover", text: 'An object', visible: true
    )

    expect(page).to have_css('.gallery-document a div.fake-cover-text', text: 'Car : a drama of the American workplace', visible: :hidden)

    expect(page).to have_css('.gallery-document h3.index_title', text: 'An object')
    expect(page).to have_css('.gallery-document button.btn-preview', text: 'Preview')
    expect(page).to have_css('form.bookmark_toggle label.toggle_bookmark', text: 'Select')
    expect(page).to have_css("label[for='toggle_bookmark_1']", count: 1)
    page.first('button.btn.docid-1').click
    expect(page).to have_css("label[for='toggle_bookmark_1']", count: 1)
    within '.preview-container' do
      expect(page).to have_css('h3', text: 'An object')
    end
  end
end
