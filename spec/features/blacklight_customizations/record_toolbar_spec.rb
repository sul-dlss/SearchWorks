require 'spec_helper'

feature "Record Toolbar" do
  before do
    stub_oclc_response('', for: '12345')
    visit root_path
  end

  scenario "should have record toolbar visible but no back to search or pagination", js: true do
    visit '/view/1'
    within "#content" do
      within "div.record-toolbar" do
        expect(page).not_to have_css("button.navbar-toggler", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Back to results", visible: true)
        expect(page).not_to have_css("a.previous.disabled", visible: true)
        expect(page).not_to have_css("a.previous", visible: true)
        expect(page).not_to have_css("a.next.disabled", visible: true)
        expect(page).not_to have_css("a.next", visible: true)
      end

      within "div.navbar-collapse" do
        expect(page).to have_css("li a", text: "Cite")
        expect(page).to have_css("li button", text: "Send to")
        expect(page).to have_css("form label", text: "Select")
      end
    end
  end

  scenario 'does not have a previous pagination button for the first item in a result', js: true do
    visit search_catalog_path f: { format: ['Book'] }
    within(first('.document')) do
      find('h3.index_title a').click
    end

    expect(page).not_to have_css('a.previous', visible: true)
  end

  scenario 'a citable item has export links', js: true do
    visit search_catalog_path f: { format: ['Book'] }
    page.find('a', text: 'An object').click

    within '#content' do
      within 'div.navbar-collapse', visible: true do
        click_button 'Send to'
        expect(page).to have_css('li a', text: 'RefWorks')
        expect(page).to have_css('li a', text: 'EndNote')
      end
    end
  end

  scenario "should have back to search and pagination", js: true do
    visit search_catalog_path f: { format: ["Book"] }

    # Specifically trying to not get the first item in the results
    within '.document-position-1' do
      page.find('h3 a').click
    end

    within "#content" do
      within "div.record-toolbar" do
        expect(page).not_to have_css("button.navbar-toggler", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Back to results", visible: true)
        expect(page).to have_css("a.previous", visible: true)
        expect(page).to have_css("a.next", visible: true)
      end
      within "div.navbar-collapse" do
        expect(page).to have_css("li button", text: "Send to")
        expect(page).to have_css("form label", text: "Select")
        click_button "Send to"
        expect(page).to have_css("li a", text: "text")
        expect(page).to have_css("li a", text: "email")
        expect(page).to have_css("li a", text: "printer")
      end
    end
  end
end
