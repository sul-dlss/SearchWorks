require "spec_helper"

feature "Databases Access Point" do
  before do
    visit databases_path
  end
  scenario "Database Topic facet should be present and uncollapsed" do
    expect(page).to have_title("Databases in SearchWorks")
    within("#facets") do
      within(".blacklight-db_az_subject") do
        expect(page).to_not have_css(".collapsed")
        expect(page).to have_css(".panel-title", text: "Database topic")
      end
    end
  end
  scenario "database topics should be present" do
    expect(page).to have_css('dt', text: "Database topics")
    expect(page).to have_css('dd a', text: "Biology")
  end
end
