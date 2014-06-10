require "spec_helper"

feature "Gallery View" do
  scenario "Search results", js: true do
    visit catalog_index_path f: {format: ["Book"]}, view: "default"
    click_link "Gallery"
    expect(page).to have_css("span.glyphicon.glyphicon-gallery.view-icon-gallery")
    expect(page).to have_css("span.caption", text: "Gallery")
    expect(page).to have_css(".document a span.fake-cover", text: "An object", visible: true)
    expect(page).to_not have_css(".document a div.fake-cover-text", text: "Car : a drama of the American workplace", visible: true)
    expect(page).to have_css(".document h5.index_title", text: "An object")
    expect(page).to have_css(".document button.btn-primary", text: "Preview")
    expect(page).to have_css("form.bookmark_toggle label.toggle_bookmark", text: "Select")
  end
end
