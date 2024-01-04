# encoding: UTF-8

require 'rails_helper'

RSpec.feature "Results Toolbar", js: true do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario "should have desktop tools visible" do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within ".sort-and-per-page" do
      within "div.page_links" do
        expect(page).to have_no_css("a.btn.btn-sul-toolbar", text: /Previous/)
        expect(page).to have_css("span.page_entries", text: /1 - 20/, visible: true)
        expect(page).to have_css("a.btn.btn-sul-toolbar", text: /Next/, visible: true)
      end
      expect(page).to have_css("div#view-type-dropdown button.dropdown-toggle")
      expect(page).to have_css("div#sort-dropdown", text: "Sort by relevance", visible: true)
      expect(page).to have_css("#select_all-dropdown .select-all", text: "Select all")
      expect(page).to have_css("#select_all-dropdown .unselect-all", text: "Unselect all", visible: false)
      expect(page).to have_no_css("a", text: /Cite/)
      expect(page).to have_no_css("button", text: /Send/)
    end
  end
  scenario "pagination links for single items should not have any number of results info" do
    visit root_path
    fill_in "q", with: '24'
    click_button 'search'

    within('.sul-toolbar') do
      expect(page).to have_css('.page_links')
      expect(page).to have_no_content('1 entry')
    end
  end
  scenario "pagination links for multiple items but no pages should not have any number of results info" do
    visit root_path q: '34'

    expect(page).to have_css('h2', text: '4 catalog results')

    within('.sul-toolbar .page_links') do
      expect(page).to have_no_css("a.btn.btn-sul-toolbar", text: /Previous/)
      expect(page).to have_css("span.page_entries", text: /1 - 4/)
      expect(page).to have_no_css("a.btn.btn-sul-toolbar", text: /Next/)
    end
  end
end
