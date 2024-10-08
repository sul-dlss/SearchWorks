# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Record Toolbar" do
  let(:citation) { instance_double(Citation) }

  before do
    allow(Citation).to receive(:new).and_return(citation)
    allow(citation).to receive_messages(all_citations: { 'mla' => '<p class="citation_style_MLA">MLA Citation</p>' }, citable?: true)
    visit root_path
  end

  scenario "should have record toolbar visible but no back to search or pagination", :js do
    visit '/view/1'
    within "#content" do
      within "div.record-toolbar" do
        expect(page).to have_no_css("button.navbar-toggler", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Back to results", visible: true)
        expect(page).to have_no_css("a.previous.disabled", visible: true)
        expect(page).to have_no_css("a.previous", visible: true)
        expect(page).to have_no_css("a.next.disabled", visible: true)
        expect(page).to have_no_css("a.next", visible: true)
      end

      within "div.navbar-collapse" do
        expect(page).to have_css("li a", text: "Cite")
        expect(page).to have_css("li button", text: "Send to")
        expect(page).to have_css("form label", text: "Select")
      end
    end
  end

  scenario 'does not have a previous pagination button for the first item in a result', :js do
    visit search_catalog_path f: { format: ['Book'] }
    within(first('.document')) do
      find('h3.index_title a').click
    end

    expect(page).to have_no_css('a.previous', visible: true)
  end

  scenario 'a citable item has export links', :js do
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

  scenario "should have back to search and pagination", :js do
    visit search_catalog_path f: { format: ["Book"] }

    # Specifically trying to not get the first item in the results
    within '.document-position-2' do
      page.find('h3 a').click
    end

    within "#content" do
      within "div.record-toolbar" do
        expect(page).to have_no_css("button.navbar-toggler", visible: true)
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
