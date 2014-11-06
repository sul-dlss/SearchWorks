require "spec_helper"

feature "Online Access Panel" do
  scenario "for databases" do
    visit catalog_path('24')

    within(".panel-online") do
      within(".panel-heading") do
        expect(page).to have_content("Search this database")
      end
      within(".panel-footer") do
        expect(page).to have_css("a", text: "Connect from off campus")
        expect(page).to have_css("a", text: "Report a connection problem")
      end
    end
  end
end
