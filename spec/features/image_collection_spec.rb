require 'rails_helper'

RSpec.feature "Image Collection", :js do
  before do
    stub_article_service(docs: [])
  end

  scenario "Search results" do
    visit root_path

    fill_in "q", with: "29"
    page.find('button#search').click

    expect(page).to have_css("h3 a", text: "Image Collection1") #title
    expect(page).to have_css("[data-behavior='metadata-truncate']", text: /Nunc venenatis et odio ac elementum/) # truncated summary
  end

  scenario "Record view" do
    visit solr_document_path('29')

    expect(page).to have_css("h1", text: "Image Collection1") # Title
    expect(page).to have_css('h3', text: "Subjects")
    expect(page).to have_css('h3', text: "Bibliographic information")
    expect(page).to have_css('h3', text: "Access conditions")

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css(".viewport .container-images")

      within ".viewport .container-images" do
        expect(page).to have_css("a[href='/view/mf774fs2413']")
      end
    end
  end

  scenario "Search results image filmstrip" do
    visit root_path

    fill_in "q", with: "29"
    find('button#search').click

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css(".viewport .container-images")

      within ".viewport .container-images" do
        expect(page).to have_css("li[data-behavior='preview-filmstrip']")
        expect(page).to have_css("a[href='/view/mf774fs2413']")
      end
    end
  end

  scenario "Search results image filmstrip preview" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      # Not really sure why this has to be visible: false in the test under chromedriver.  It is visible in the page.
      expect(page).to have_css("div.preview-filmstrip-container-29", visible: false)
    end
  end
end
