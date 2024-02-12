require 'rails_helper'

RSpec.describe "Librarian View Customization", :js do
  let(:embed) { double('embed-response') }

  it "MARC records should display" do
    visit solr_document_path('28')

    within(".tech-details") do
      expect(page).to have_content('Catkey: 28')

      click_link('Librarian view')
    end

    expect(page).to have_css('.modal-title', text: "Librarian View", visible: true)

    find('details:first-of-type > summary').click
    within("#marc_view") do
      expect(page).to have_css(".field", text: /Some intersting papers/)
    end
  end

  it "MODS records should display" do
    expect(embed).to receive(:html).and_return("")
    expect(PURLEmbed).to receive(:new).and_return(embed)
    visit solr_document_path('35')

    within(".tech-details") do
      expect(page).to have_content('DRUID: 35')

      click_link('Librarian view')
    end

    expect(page).to have_css('.modal-title', text: "Librarian View", visible: true)

    within(".mods-view") do
      expect(page).to have_content("A record with everything")
      expect(page).to have_css("span", text: "<title>")
    end
  end
end
