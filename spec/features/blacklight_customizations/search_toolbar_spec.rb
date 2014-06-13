require "spec_helper"

describe "Search toolbar", js: true, feature: true do
    before { visit root_path }
  describe "has SearchWorks customizations" do
    it "should display correct elements" do
      within "#search-navbar" do
        expect(page.find('button.btn.btn-primary.search-btn')).to have_no_content 'Search'
        expect(page).to have_css("li a", text: "Advanced", visible: true)
        expect(page).to have_css("li.disabled a", text: "Browse", visible: true)
        expect(page).to have_css("li a", text: /Selections/, visible: true)
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
      it "should clear selections and update selections count" do
        visit catalog_index_path f: {format: ["Book"]}, view: "default"
        expect(page).to have_css("li a", text: /Selections \(0\)/)
        page.all('label.toggle_bookmark')[0].click
        expect(page).to have_css("li a", text: /Selections \(1\)/)
        page.all('label.toggle_bookmark')[1].click
        expect(page).to have_css("li a", text: /Selections \(2\)/)
        page.all('label.toggle_bookmark')[1].click
        expect(page).to have_css("li a", text: /Selections \(1\)/)
        expect(page).to have_css("label.toggle_bookmark", text: "Selected", count: 1)
        click_link "Selections"
        click_link "Clear list"
        expect(page).to have_css("h1", text: "0 selections")
      end
    end
  end
end
