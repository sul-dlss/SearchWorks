require "spec_helper"

feature "Gallery View" do
  scenario "Search results", js: true do
    visit catalog_index_path f: {format: ["Book"]}
    page.find('#view-type-dropdown button.dropdown-toggle a').click
    page.find('#view-type-dropdown .dropdown-menu li a.view-type-gallery').click

    expect(page).to have_css("span.glyphicon.glyphicon-gallery.view-icon-gallery")
    expect(page).to have_css("div.callnumber-bar", text: "ABC")
    expect(page).to have_css("div.callnumber-bar", count: 2, text: /./)
    expect(page).to have_css(".gallery-document a span.fake-cover", text: "An object", visible: true)
    expect(page).to_not have_css(".gallery-document a div.fake-cover-text", text: "Car : a drama of the American workplace", visible: true)
    expect(page).to have_css(".gallery-document h5.index_title", text: "An object")
    expect(page).to have_css(".gallery-document button.btn-primary", text: "Preview")
    expect(page).to have_css("form.bookmark_toggle label.toggle_bookmark", text: "Select")

    page.first("button.btn.docid-1").click
    expect(page).to have_css("dt", text: "Language:")
    expect(page).to have_css("dd", text: "English.")
  end
end
