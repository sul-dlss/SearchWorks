require "spec_helper"

describe "Databases Access Point", feature: true, :"data-integration" => true do
  it "should display the database specific facet" do
    pending("Needs format/resource-type facet to settle down")
    visit root_path
    fill_in 'q', with: ''
    click_button 'search'
    within("#facets") do
      expect(page).to_not have_css('.panel-title', text: "Database topic")
      click_link "Database"
    end

    within("#facets") do
      within(".blacklight-db_az_subject") do
        expect(page).to_not have_css(".collapsed")
        expect(page).to have_css(".panel-title", text: "Database topic")
      end
    end
  end
  it "should be present when selecting the databases facet" do
    pending("Needs format/resource-type facet to settle down")
    visit root_url

    fill_in "q", with: ''
    click_button "search"

    within("#facet-format") do
      click_link "Database"
    end
    within("#masthead") do
      expect(page).to have_css("h1", text: "Databases")
    end
  end
  it "should sort by title by default" do
    visit databases_path

    within("#documents .document:nth-of-type(1)") do
      expect(page).to have_css("h5.index_title", text: "19th century British Library newspapers [electronic resource].")
    end

    within("#documents .document:nth-of-type(6)") do
      expect(page).to have_css("h5.index_title", text: "AAPG data systems/publications [electronic resource].")
    end
  end
  it "should filter by letter" do
    visit databases_path

    expect(page).to have_css("h5.index_title", text: "19th century British Library newspapers [electronic resource].")
    expect(page).not_to have_css("h5.index_title", text: "Handbook of Latin American studies")

    within(".database-prefix .pagination") do
      click_link "H"
    end

    expect(page).not_to have_css("h5.index_title", text: "19th century British Library newspapers [electronic resource].")
    expect(page).to have_css("h5.index_title", text: "Handbook of Latin American studies")
  end
end