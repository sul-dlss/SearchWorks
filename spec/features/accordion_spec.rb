require 'spec_helper'

feature "Accordion", js: true do
  before do
    visit root_path
    fill_in "q", with: "20"
    click_button 'search'
  end
  scenario "should not have content with a title tooltip" do
    within ".accordion-section.summary" do
      expect(page).to_not have_xpath("//div[@class='snippet 20-summary-snippet'][@title]", text: "A summary of the database, this needs to be long s…")
    end
  end
end
