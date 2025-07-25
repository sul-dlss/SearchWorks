# frozen_string_literal: true

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
    expect(page).to have_css("div.truncate-2", text: /Nunc venenatis et odio ac elementum/) # truncated summary
  end

  scenario "Record view" do
    visit solr_document_path('29')

    expect(page).to have_css("h1", text: "Image Collection1") # Title
    expect(page).to have_css('h2', text: "Subjects")
    expect(page).to have_css('h2', text: "Bibliographic information")
    expect(page).to have_css('h2', text: "Access conditions")

    expect(page).to have_css(".image-filmstrip")

    within "div.image-filmstrip" do
      expect(page).to have_css(".viewport .container-images")

      within ".viewport .container-images" do
        expect(page).to have_css("a[href='/view/mf774fs2413']")
      end
    end
  end
end
