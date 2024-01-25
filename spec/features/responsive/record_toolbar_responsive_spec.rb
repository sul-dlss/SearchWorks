require 'rails_helper'

RSpec.describe "Record toolbar", :feature, :js do
  before do
    stub_oclc_response('', for: '12345')
  end

  describe " - tablet view (768px - 980px) - " do
    before { visit search_catalog_path f: { format: ['Book'] } }

    context 'a citable item' do
      before { page.find('a', text: 'An object').click }

      it 'should display a cite this link toolbar items' do
        expect(page).to have_css('div.record-toolbar', visible: true)
        within '#content' do
          within 'div.navbar-collapse' do
            expect(page).to have_css('li a', text: 'Cite')
          end
        end
      end
    end

    context 'any item' do
      before do
        # Specifically trying to not get the first item in the results
        within '.document-position-2' do
          page.find('h3 a').click
        end
      end

      it "should display all toolbar items" do
        within "#content" do
          expect(page).to have_css("div.record-toolbar", visible: true)

          within "div.record-toolbar" do
            expect(page).to have_no_css("button.navbar-toggler", visible: true)
            expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Back to results", visible: true)
            expect(page).to have_css("a.previous", visible: true)
            expect(page).to have_css("a.next", visible: true)
          end

          within "div.navbar-collapse" do
            expect(page).to have_css("li button", text: "Send to")
            expect(page).to have_css("form label", text: "Select")
          end
        end
      end
    end
  end

  describe " - mobile landscape view (480px - 767px) - ", :responsive, page_width: 700 do
    before { visit search_catalog_path f: { format: ['Book'] } }

    context 'a citable item' do
      before { page.find('a', text: 'An object').click }

      it 'renders a cite this link' do
        within '#content' do
          expect(page).to have_css('div.record-toolbar', visible: true)

          page.find("button.navbar-toggler").click

          within 'div.navbar-collapse' do
            expect(page).to have_css('li a', text: 'Cite', visible: true)
            expect(page).to have_no_css("li a", text: "RefWorks", visible: true)
            expect(page).to have_no_css("li a", text: "EndNote", visible: true)
          end
        end
      end
    end

    context 'any item' do
      before do
        # Specifically trying to not get the first item in the results
        within '.document-position-2' do
          page.find('h3 a').click
        end
      end

      it "should display correct toolbar items" do
        within "#content" do
          expect(page).to have_css("div.record-toolbar", visible: true)

          within "div.record-toolbar" do
            expect(page).to have_css("button.navbar-toggler", visible: true)
            expect(page).to have_css("a.btn.btn-sul-toolbar", text: "", visible: true)
            expect(page).to have_css("a.previous", visible: true)
            expect(page).to have_css("a.next", visible: true)
          end

          expect(page).to have_no_css("div.navbar-collapse", visible: true)

          page.find("button.navbar-toggler").click

          within "div.navbar-collapse" do
            expect(page).to have_css("li button", text: "Send to", visible: true)
            expect(page).to have_css("form label", text: "Select", visible: true)
            expect(page).to have_no_css("li a", text: "text", visible: true)
            expect(page).to have_no_css("li a", text: "email", visible: true)
            expect(page).to have_no_css("li a", text: "printer", visible: true)
            click_button "Send to"
            expect(page).to have_css("li a", text: "text", visible: true)
            expect(page).to have_css("li a", text: "email", visible: true)
            expect(page).to have_css("li a", text: "printer", visible: true)
          end
        end
      end
    end
  end
end
