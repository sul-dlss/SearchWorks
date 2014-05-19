require "spec_helper"

feature "Databases Access Point" do
  before do
    visit databases_path
  end
  scenario "Database Topic facet should be present and uncollapsed" do
    within("#facets") do
      within(".blacklight-db_az_subject") do
        expect(page).to_not have_css(".collapsed")
        expect(page).to have_css(".panel-title", text: "Database topic")
      end
    end
  end
end
