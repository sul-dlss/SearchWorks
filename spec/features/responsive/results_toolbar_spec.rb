require "spec_helper"

describe "Responsive results toolbar", js: true, feature: true do
  before do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'
  end
  describe " - desktop view (> 992px)" do
    it "should display correct tools" do
      within "#sortAndPerPage" do
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "NEXT", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "PREVIOUS", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar span.glyphicon.glyphicon-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "VIEW", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "SORT BY RELEVANCE", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "10 PER PAGE", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "SELECT ALL", visible: true)
      end
    end
  end
  describe " - tablet view (768px - 992px) - " do
    it "should display correct tools" do
      within "#sortAndPerPage" do
        page.driver.resize("800", "800")
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "NEXT", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "PREVIOUS", visible: true)
        expect(page).to_not have_css("button.btn.btn-sul-toolbar span.glyphicon.glyphicon-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "VIEW", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "10", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "ALL", visible: true)
      end
    end
  end
  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct tools" do
      page.driver.resize("700", "700")
      within "#sortAndPerPage" do
        expect(page).to_not have_css("a.btn.btn-sul-toolbar", text: "NEXT", visible: true)
        expect(page).to_not have_css("a.btn.btn-sul-toolbar", text: "PREVIOUS", visible: true)
        expect(page).to_not have_css("button.btn.btn-sul-toolbar span.glyphicon.glyphicon-list", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "VIEW", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "10", visible: true)
        expect(page).to have_css("button.btn.btn-sul-toolbar", text: "ALL", visible: true)
      end
    end
  end
end
