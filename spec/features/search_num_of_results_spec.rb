require 'rails_helper'

RSpec.feature "Search results count" do
  scenario "should display number of results header" do
    visit search_catalog_path f: { format: ["Book"] }
    within "#content" do
      within ".search_num_of_results" do
        expect(page).to have_css("h2", text: /[\d,]+ catalog results?/)
      end
    end
  end
end
