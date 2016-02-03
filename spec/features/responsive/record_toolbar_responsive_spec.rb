require "spec_helper"

describe "Record toolbar", js: true, feature: true do
  before do
    stub_oclc_response('', for: '12345')
    visit catalog_index_path f: {format: ["Book"]}
    page.find("a", text: "An object").click
  end

  describe " - tablet view (768px - 980px) - " do
    it "should display all toolbar items" do
      within "#content" do
        expect(page).to have_css("div.record-toolbar", visible: true)

        within "div.navbar-header" do
          expect(page).to_not have_css("button.navbar-toggle", visible: true)
          expect(page).to have_css("a.btn.btn-sul-toolbar", text:"Back to results", visible: true)
          expect(page).to have_css("a.previous", visible: true)
          expect(page).to have_css("a.next", visible: true)
        end

        within "div.navbar-collapse" do
          expect(page).to have_css("li a", text: "Cite")
          expect(page).to have_css("li button", text: "Send to")
          expect(page).to have_css("form label", text: "Select")
        end
      end
    end
  end

  describe " - mobile landscape view (480px - 767px) - " do
    it "should display correct toolbar items" do
      page.driver.resize("700", "700")
      within "#content" do
        expect(page).to have_css("div.record-toolbar", visible: true)

        within "div.navbar-header" do
          expect(page).to have_css("button.navbar-toggle", visible: true)
          expect(page).to have_css("a.btn.btn-sul-toolbar", text:"", visible: true)
          expect(page).to have_css("a.previous", visible: true)
          expect(page).to have_css("a.next", visible: true)
        end

        expect(page).to_not have_css("div.navbar-collapse", visible: true)

        page.find("button.navbar-toggle").click

        within "div.navbar-collapse" do
          expect(page).to have_css("li a", text: "Cite", visible: true)
          expect(page).to have_css("li button", text: "Send to", visible: true)
          expect(page).to have_css("form label", text: "Select", visible: true)
          expect(page).to_not have_css("li a", text: "text", visible: true)
          expect(page).to_not have_css("li a", text: "email", visible: true)
          expect(page).to_not have_css("li a", text: "RefWorks", visible: true)
          expect(page).to_not have_css("li a", text: "EndNote", visible: true)
          expect(page).to_not have_css("li a", text: "printer", visible: true)
          click_button "Send to"
          expect(page).to have_css("li a", text: "text", visible: true)
          expect(page).to have_css("li a", text: "email", visible: true)
          expect(page).to have_css("li a", text: "RefWorks", visible: true)
          expect(page).to have_css("li a", text: "EndNote", visible: true)
          expect(page).to have_css("li a", text: "printer", visible: true)
        end
      end
    end
  end

end
