require "spec_helper"

feature "Course Reserve Access Point" do
  before do
    visit catalog_index_path({f: {course: ["CAT-401-01-01"], instructor: ["McDonald, Ronald"]}})
  end
  scenario "Access point masthead should be visible with 1 course reserve document" do
    expect(page).to have_title("Course reserves in SearchWorks")
    within("#masthead") do
      expect(page).to have_css("h1", text: "Course reserve list: CAT-401-01-01")
      expect(page).to have_css("p", text: "CAT-401-01-01 -- Emergency Kittenz")
      expect(page).to have_css("p", text: "INSTRUCTOR: McDonald, Ronald")
    end
    within("#content") do
      expect(page).to have_css("div.document", count:1)
    end
  end
end
