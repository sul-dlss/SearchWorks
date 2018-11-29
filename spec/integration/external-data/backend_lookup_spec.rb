require "spec_helper"

describe "Backend lookup", type: :feature, js: true, :"data-integration" => true do
  before do
    visit root_path
  end

  describe "on search results" do
    before do
      click_on "Online"
      fill_in 'q', with: 'Search'
      click_button 'search'
    end

    it "should not execute until scrolled to" do
      expect(page).to     have_css('a', text: /^Remove limit\(s\)$/)
      expect(page).not_to have_css('a', text: /^Remove limit\(s\) \.{3} found \d{4,} results$/)
      page.driver.scroll_to(0, 10000)
      expect(page).to have_css('a', text: /^Remove limit\(s\) \.{3} found \d{4,} results$/)
    end
  end
end
