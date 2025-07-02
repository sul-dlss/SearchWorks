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
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Search results", visible: true)
        expect(page).to have_no_css("a.previous.disabled", visible: true)
        expect(page).to have_no_css("a.previous", visible: true)
        expect(page).to have_no_css("a.next.disabled", visible: true)
        expect(page).to have_no_css("a.next", visible: true)
      end

      within ".navbar" do
        expect(page).to have_css("form label", text: "Bookmark")
        expect(page).to have_link('Cite')
        expect(page).to have_link('Email')
        expect(page).to have_button('Copy link')
        expect(page).to have_button('Print')
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

  scenario "should have back to search and pagination", :js do
    visit search_catalog_path f: { format: ["Book"] }

    # Specifically trying to not get the first item in the results
    within '.document-position-2' do
      page.find('h3 a').click
    end

    within "#content" do
      within "div.record-toolbar" do
        expect(page).to have_no_css("button.navbar-toggler", visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: "Search results", visible: true)
        expect(page).to have_css("a.previous", visible: true)
        expect(page).to have_css("a.next", visible: true)
      end
    end
  end
end
