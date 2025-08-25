# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "File Collection" do
  scenario "Search results" do
    stub_article_service(docs: [])
    visit root_path

    fill_in "q", with: "31"
    click_button 'search'

    expect(page).to have_css("h3 a", text: "File Collection1") #title
    expect(page).to have_css("div[data-controller='long-text']", text: /Nunc venenatis et odio ac elementum/) # truncated summary
  end

  scenario "Record view" do
    visit solr_document_path('31')

    expect(page).to have_css("h1", text: "File Collection1") # Title
    expect(page).to have_css('h2', text: "Subjects")
    expect(page).to have_css('h2', text: "Bibliographic information")
    expect(page).to have_css('h2', text: "Access conditions")
  end
end
