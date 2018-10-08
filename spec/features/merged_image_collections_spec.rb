require "spec_helper"

feature "Merged Image Collections", js: true do
  before do
    stub_article_service(docs: [])
  end
  scenario "in search results" do
    visit root_path
    fill_in 'q', with: '34'
    click_button 'search'

    expect(page).to have_css('dt', text: 'DIGITAL CONTENT')
    expect(page).to have_css('dd', text: /\d+ items?/)

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

    expect(page).to have_css('h2', text: 'Contents/Summary')
    expect(page).to have_css('h2', text: 'Subjects')
    expect(page).to have_css('h2', text: 'Bibliographic information')
  end
end
