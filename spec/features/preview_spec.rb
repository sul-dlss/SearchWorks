require "spec_helper"

feature "Preview routes functionality" do
  scenario "at show route" do
    visit preview_path(1)
    expect(page).to have_css("h4 a", text: "An object")
  end
end

feature "Preview integration with plugin" do
  pending
end
