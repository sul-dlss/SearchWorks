# encoding: UTF-8

require "spec_helper"

describe "Callnumber browse", feature: true, "data-integration": true do
  it "should have an embedded panel on the record page" do
    visit solr_document_path('9696118')
    within('.record-browse-nearby') do
      expect(page).to have_css('button', text: 'PS3552 .E74 B4 2012')
      expect(page).to have_css('button', text: 'Z239 .G75 B477 2012')
      click_button('Z239 .G75 B477 2012')
    end
    expect(page).to have_css("h1", text: "Browse related items")
    expect(page).to have_css('p', text: /Starting at call number:.*Z239 .G75 B477 2012/m)
    expect(page).to have_css('.gallery-document', count: 20)

    # current document should be in results
    expect(page).to have_css('.gallery-document .index_title', text: "Bean spasms : collaborations")

    # page forward
    within('.browse-toolbar') do
      click_link('►')
    end

    # current document should not be in results
    expect(page).not_to have_css('.index_title', text: "Bean spasms : collaborations")
  end
end
