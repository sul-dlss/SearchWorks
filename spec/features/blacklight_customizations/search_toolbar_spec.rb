require "spec_helper"

describe "Search toolbar", js: true, feature: true do
    before { visit root_path }
  describe "has SearchWorks customizations" do
    it "should display correct elements" do
      within "#search-navbar" do
        expect(page).to have_css("button.btn.btn-primary.search-btn", text: "")
        expect(page).to have_css("li a", text: "ADVANCED", visible: true)
        expect(page).to have_css("li.disabled a", text: "BROWSE", visible: true)
        expect(page).to have_css("li a", text: /SELECTIONS/, visible: true)
      end
    end
  end
  describe "Selections dropdown" do
    describe "show list" do
      it "should navigate to selections page" do
        visit selections_path
        expect(page).to have_css("h1", text: "0 selections")
        expect(page).to have_css("h3", text: "You have no bookmarks")
      end
    end
    describe "clear list", js:true do
      it "should clear selections and update selections count and recently added list" do
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
        expect(page).to have_css("h4", text: "Limit your search")
      end
    end
  end
end
