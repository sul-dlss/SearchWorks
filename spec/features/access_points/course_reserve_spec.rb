require 'rails_helper'

RSpec.feature "Course Reserve Access Point" do
  before do
    visit search_catalog_path({ f: { course: ["CAT-401-01-01"], instructor: ["McDonald, Ronald"] } })
  end

  scenario "Access point masthead is visible with 1 course reserve document" do
    expect(page).to have_title("Course reserves in SearchWorks catalog")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Course reserve list: CAT-401-01-01")
      expect(page).to have_css("dt", text: "Instructor")
      expect(page).to have_css("dd", text: "McDonald, Ronald")
      expect(page).to have_css("dt", text: "Course")
      expect(page).to have_css("dd", text: "CAT-401-01-01 -- Emergency Kittenz")
    end
    within("#content") do
      expect(page).to have_css(".document", count: 1)
    end
  end
end
