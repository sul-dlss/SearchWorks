require "spec_helper"

feature "Image Collection" do
  scenario "Search results" do
    visit root_path

    fill_in "q", with: "29"
    click_button 'search'

    expect(page).to have_css("h5 a", text: "Image Collection1") #title
    expect(page).to have_css("[data-behavior='truncate']", text: /A collection of fixture images/) # truncated summary
    expect(page).to have_css("dt", text: "DIGITAL CONTENT")
    expect(page).to have_css("dd", text: /\d+ items?/) # collection members
  end

  scenario "Record view" do
    visit catalog_path('29')

    expect(page).to have_css("h1", text: "Image Collection1") # Title
    expect(page).to have_css("h2", text: "Subjects")
    expect(page).to have_css("h2", text: "Bibliographic information")
    expect(page).to have_css("h2", text: "Access conditions")
  end
end
