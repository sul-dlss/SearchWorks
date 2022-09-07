require "spec_helper"

describe "Responsive results toolbar", js: true, feature: true do
  describe " - desktop view (> 992px)" do
    it "should display correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within ".sort-and-per-page" do
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Next", visible: true)
        expect(page).not_to have_css("a.btn.btn-sul-toolbar", text: "Previous", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar i.fa.fa-th-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "View", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "Sort by relevance", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "20 per page", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "Select all", visible: true)
      end
    end
  end

  describe " - tablet view (768px - 992px) - ", responsive: true, page_width: 800 do
    it "should display correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within ".sort-and-per-page" do
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Next", visible: true)
        expect(page).not_to have_css("a.btn.btn-sul-toolbar", text: "Previous", visible: true)
        expect(page).not_to have_css("button.btn.btn-sul-toolbar i.fa.fa-th-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "View", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "20", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "all", visible: true)
      end
    end
  end

  describe " - mobile landscape view (480px - 767px) - ", responsive: true, page_width: 700 do
    it "should display correct tools" do
      visit root_path
      fill_in "q", with: ''
      click_button 'search'

      within ".sort-and-per-page" do
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Next", visible: false)
        expect(page).not_to have_css("a.btn.btn-sul-toolbar", text: "Previous", visible: false)
        expect(page).not_to have_css("button.btn.btn-sul-toolbar i.fa.fa-th-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "View", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "20", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "all", visible: true)
      end
    end
  end
end
