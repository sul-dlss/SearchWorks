# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Results Toolbar" do
  before do
    stub_article_service(docs: StubArticleService::SAMPLE_RESULTS)
  end

  scenario "should have desktop tools visible" do
    visit root_path
    fill_in "q", with: ''
    click_button 'search'

    within ".sort-and-per-page" do
      within ".page_links" do
        expect(page).to have_no_link('Previous')
        expect(page).to have_css(".page_entries", text: /1 - 20/, visible: true)
        expect(page).to have_link('Next', visible: true)
      end
      expect(page).to have_css("div#sort-dropdown", text: "Sort by relevance", visible: true)
      expect(page).to have_no_css("a", text: /Cite/)
      expect(page).to have_no_css("button", text: /Send/)
      expect(page).to have_css('[data-controller="analytics"][data-analytics-category-value="per-page"]')
      expect(page).to have_css('[data-controller="analytics"][data-analytics-category-value="sort-type"]')
      expect(page).to have_css('a[data-action="click->analytics#trackLink"]', visible: :all, count: 10)
    end
  end

  scenario "pagination links for single items should not have any number of results info" do
    visit root_path
    fill_in "q", with: '24'
    click_button 'search'
    within('.sort-and-per-page') do
      expect(page).to have_css('.page_links')
      expect(page).to have_no_content('1 entry')
    end
  end

  scenario "pagination links don't display when there is only one page of results" do
    visit root_path q: '34'

    within('.page_links') do
      expect(page).to have_no_link('Previous')
      expect(page).to have_css(".page_entries", text: /1 - 7/)
      expect(page).to have_no_link('Next')
    end
  end
end
