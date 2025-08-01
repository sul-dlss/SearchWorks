# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Merged Image Collections", :js do
  scenario "record view displays metadata and filmstrip" do
    visit solr_document_path('34')

    expect(page).to have_css('h1', text: 'Merged Image Collection1')

    expect(page).to have_no_css('.managed-purl').and have_no_css('[data-controller="purl-embed"]')

    within('.image-filmstrip') do
      within('ul.container-images') do
        expect(page).to have_css("a img.thumb-35")
        expect(page).to have_css("li[data-preview-embed-browse-url-value$='/preview/35']")

        expect(page).to have_css("a img.thumb-36")
        expect(page).to have_css("li[data-preview-embed-browse-url-value$='/preview/36']")
      end
    end

    expect(page).to have_css('h2', text: 'Contents/Summary')
    expect(page).to have_css('h2', text: 'Subjects')
    expect(page).to have_css('h2', text: 'Bibliographic information')
  end
end
