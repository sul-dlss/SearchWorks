require "spec_helper"

feature "Databases Access Point" do
  before do
    visit databases_path
  end
  scenario "should have a custom masthead" do
    expect(page).to have_title("Databases in SearchWorks catalog")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Databases")
      expect(page).to have_css("a", text: "Find articles")
      expect(page).to have_css("a", text: "Connect from off campus")
      expect(page).to have_css("a", text: "Report a connection problem")
    end
  end
  scenario "Database Topic facet should be present and uncollapsed" do
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

  scenario 'databases should be able to be prefix filtered' do
    expect(page).to have_css('h2', text: '8 catalog results')

    within '.database-prefix' do
      click_link 'S'
    end

    expect(page).to have_css('h2', text: '4 catalog results')
    expect(page).to have_css('h3', text: /Selected Database \d/, count: 4)
  end
end
