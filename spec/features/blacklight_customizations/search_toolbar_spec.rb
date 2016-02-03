require "spec_helper"

describe "Search toolbar", js: true, feature: true do
  before { visit root_path }
  describe "has SearchWorks customizations" do
    it "should display correct elements" do
      within "#search-navbar" do
        expect(page).to have_css("button.btn.btn-default.search-btn", text: "")
        expect(page).to have_css("li a", text: "ADVANCED", visible: true)
        expect(page).to have_css("li a", text: "BROWSE", visible: true)
        expect(page).to have_css("li a", text: /SELECTIONS/, visible: true)
      end
    end
  end
  describe "Browse dropdown" do
    it "should have browse links" do
      click_link "Browse"
      expect(page).to have_css("ul.dropdown-menu li a", text: "Course reserves")
    end
  end
  describe "Selections dropdown" do
    describe "show list" do
      it "should navigate to selections page" do
        visit selections_path
        expect(page).to have_css("h2", text: "0 selections")
        expect(page).to have_css("h3", text: "You have no bookmarks")
      end
    end
    describe "clear list", js:true do
      it "should clear selections and update selections count and recently added list" do
        skip("Passes locally, not on Travis.") if ENV['CI']
        visit catalog_index_path f: {format: ["Book"]}, view: "default"
        expect(page).to have_css("li a", text: /SELECTIONS \(0\)/)
        click_link "Selections"
        expect(page).to have_css("li#show-list.disabled")
        expect(page).to have_css("li#clear-list.disabled")
        page.all('label.toggle_bookmark')[0].click
        expect(page).to have_css("li a", text: /SELECTIONS \(1\)/)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 1)
        page.all('label.toggle_bookmark')[1].click
        expect(page).to have_css("li a", text: /SELECTIONS \(2\)/)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 2)
        page.all('label.toggle_bookmark')[1].click
        expect(page).to have_css("li a", text: /SELECTIONS \(1\)/)
        click_link "Selections"
        expect(page).to have_css("li.dropdown-list-title", count: 1)
        click_link "Selections"
        expect(page).to have_css("label.toggle_bookmark", text: "Selected", count: 1)
        click_link "Selections"
        click_link "Clear list"
        expect(page).to have_css("div.alert.alert-success", text: "Your selections have been deleted.")
        expect(page).to have_css("h2", text: "Limit your search")
      end
    end
  end
end
