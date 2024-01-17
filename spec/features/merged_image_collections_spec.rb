require 'rails_helper'

RSpec.feature "Merged Image Collections", :js do
  before do
    stub_article_service(docs: [])
  end

  scenario "in search results" do
    visit root_path
    fill_in 'q', with: '34'
    page.find('button#search').click

    within('.image-filmstrip') do
      within('ul.container-images') do
        expect(page).to have_css("a img.thumb-35")
        expect(page).to have_css("a img.thumb-36")
      end

      within('ul.container-images') do
        expect(page).to have_css("li[data-preview-url$='/preview/35']")
        expect(page).to have_css("li[data-preview-url$='/preview/36']")
      end
    end
  end

  scenario "record view should display metadata and filmstrip" do
    visit solr_document_path('34')

    expect(page).to have_css('h1', text: 'Merged Image Collection1')

    within('.image-filmstrip') do
      within('ul.container-images') do
        expect(page).to have_css("a img.thumb-35")
        expect(page).to have_css("a img.thumb-36")
      end

      within('ul.container-images') do
        expect(page).to have_css("li[data-preview-url$='/preview/35']")
        expect(page).to have_css("li[data-preview-url$='/preview/36']")
      end
    end

    expect(page).to have_css('h3', text: 'Contents/Summary')
    expect(page).to have_css('h3', text: 'Subjects')
    expect(page).to have_css('h3', text: 'Bibliographic information')
  end
end
